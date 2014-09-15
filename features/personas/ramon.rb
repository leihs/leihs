# coding: UTF-8

# Persona:  Ramon
# Job:      Leihs Developer and Administrator
#
require "#{Rails.root}/features/support/leihs_factory.rb"

module Persona
  
  class Ramon
    
    @@name = "Ramon"
    @@lastname = "C."
    @@email = "ramon@zhdk.ch"
    
    def initialize
      setup_dependencies
      
      ActiveRecord::Base.transaction do 
        create_minimal_setup
        create_admin_user
        create_inventory_pool_a_ausleihe
        create_inventory_pool_it_ausleihe
        create_inventory_pool_av_technik
        create_inventory_pool_deletable
        create_naked_users
        create_users_with_access_rights
        create_users_with_unsubmitted_contracts
        create_users_with_approved_contracts
        create_users_with_deleted_access_rights_and_closed_contracts
        become_customer_of_inventory_pool_a_ausleihe
      end
    end
    
    def setup_dependencies 
      # no dependencies for ramon
    end
    
    def create_minimal_setup
      # i comment it out for now. it makes troubles (see commit 8d22129f661e538e30888854cfb490292ddcb6a0) and settings entry is created in the migration anyway.
      # FactoryGirl.create :setting unless Setting.first

      LeihsFactory.create_default_languages
      LeihsFactory.create_default_authentication_systems
      LeihsFactory.create_default_building
    end
    
    def create_admin_user
      @language = Language.find_by_locale_name "de-CH"
      @user = FactoryGirl.create(:user, :language => @language, :firstname => @@name, :lastname => @@lastname, :login => @@name.downcase, :email => @@email)
      @user.access_rights.create(:role => :admin)
    end
    
    def create_inventory_pool_a_ausleihe
      description = "Wichtige Hinweise...\n Bitte die Gegenstände rechtzeitig zurückbringen"
      contact_details = "A Verleih  /  ZHdK\nav@zh-dk.ch\n+41 00 00 00 00"
      @a_ausleihe = FactoryGirl.create(:inventory_pool, :name => "A-Ausleihe", :description => description, :contact_details => contact_details, :contract_description => "Gerät erhalten", :email => "av@zhdk.ch", :shortname => "A", :default_contract_note => Faker::Lorem.sentence, :automatic_suspension => true, :automatic_suspension_reason => Faker::Lorem.sentence)
      create_christmas_holiday @a_ausleihe
    end

    def create_christmas_holiday inventory_pool
      (0..1).each do |n|
        christmas = Date.new(Date.today.year + n, 12, 24)
        inventory_pool.holidays.create(start_date: christmas, end_date: christmas + 2.days, name: "Christmas")
      end
    end
    
    def create_inventory_pool_it_ausleihe
      description = "Bringt die Geräte bitte rechtzeitig zurück"
      contact_details = "IT Verleih  /  ZHdK\nav@zh-dk.ch\n+41 00 00 00 00"
      @it_ausleihe = FactoryGirl.create(:inventory_pool, :name => "IT-Ausleihe", :description => description, :contact_details => contact_details, :contract_description => "Gerät erhalten", :email => "it@zhdk.ch", :shortname => "IT", :automatic_suspension => true, :automatic_suspension_reason => Faker::Lorem.sentence)
      create_christmas_holiday @it_ausleihe
    end

    def create_inventory_pool_av_technik
      description = "Bringt die Geräte bitte rechtzeitig zurück"
      contact_details = "AV Verleih  /  ZHdK\nav@zh-dk.ch\n+41 00 00 00 00"
      @av_technik = FactoryGirl.create(:inventory_pool, :name => "AV-Technik", :description => description, :contact_details => contact_details, :contract_description => "Gerät erhalten", :email => "it@zhdk.ch", :shortname => "AV")
      create_christmas_holiday @av_technik
    end

    def create_inventory_pool_deletable
      description = "Bringt die Geräte bitte rechtzeitig zurück"
      contact_details = "AV Verleih  /  ZHdK\nav@zh-dk.ch\n+41 00 00 00 00"
      FactoryGirl.create(:inventory_pool, :name => "DT deletable", :description => description, :contact_details => contact_details, :contract_description => "Gerät erhalten", :email => "it@zhdk.ch", :shortname => "DT")
    end

    def create_naked_users
      FactoryGirl.create :user
    end

    def create_users_with_access_rights
      FactoryGirl.create :access_right, inventory_pool: @av_technik, user: FactoryGirl.create(:user), role: :customer
      FactoryGirl.create :access_right, inventory_pool: @a_ausleihe, user: FactoryGirl.create(:user), role: :lending_manager
    end

    def create_users_with_deleted_access_rights_and_closed_contracts
      user = FactoryGirl.create(:user)
      FactoryGirl.create :access_right, inventory_pool: @a_ausleihe, deleted_at: Date.today, user: user, role: :customer
      @contract = FactoryGirl.create :contract_with_lines, inventory_pool: @a_ausleihe, status: :approved, user: user
      manager = User.find_by_login "ramon"
      @contract.sign(manager)
      @contract.lines.each {|cl| cl.update_attributes(returned_date: Date.today, returned_to_user_id: manager.id)}
      @contract.close
    end

    def create_users_with_unsubmitted_contracts
      FactoryGirl.create :contract_with_lines, status: :unsubmitted
    end

    def create_users_with_approved_contracts
      FactoryGirl.create :contract_with_lines, status: :approved
    end

    def become_customer_of_inventory_pool_a_ausleihe
      @user.access_rights.create role: :customer, inventory_pool: @a_ausleihe
    end

  end
end
