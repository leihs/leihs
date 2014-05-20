# coding: UTF-8

# Persona:  Normin
# Job:      ZHDK Student
#

module Persona
  
  class Normin
    
    @@name = "Normin"
    @@lastname = "N."
    @@email = "normin@zhdk.ch"
    @@inventory_pool_names = ["A-Ausleihe", "IT-Ausleihe", "AV-Technik"]
    
    def initialize
      setup_dependencies
      
      ActiveRecord::Base.transaction do
        select_inventory_pool 
        create_user
        setup_groups
        create_submitted_contracts
        create_approved_contracts
        create_signed_contracts
        lend_package
      end
    end
    
    def setup_dependencies 
      Persona.create :mike
      @pius = Persona.create :pius
    end

    def select_inventory_pool 
      @inventory_pool = InventoryPool.find_by_name(@@inventory_pool_names.first)
      @inventory_pool_2 = InventoryPool.find_by_name(@@inventory_pool_names.second)
    end
    
    def create_user
      @language = Language.find_by_locale_name "de-CH"
      @user = FactoryGirl.create(:user, :language => @language, :firstname => @@name, :lastname => @@lastname, :login => @@name.downcase, :email => @@email)
      @@inventory_pool_names.each { |ip_name| @user.access_rights.create(:role => :customer, :inventory_pool => InventoryPool.find_by_name(ip_name)) }

      # create deactivated access right
      @user.access_rights.create(:role => :customer, :inventory_pool => InventoryPool.last, :deleted_at => Date.yesterday)
    end
    
    def create_submitted_contracts
      @camera_model = Model.find_by_name "Kamera Nikon X12"
      @tripod_model = Model.find_by_name "Kamera Stativ 123"
      @beamer_model = Model.find_by_name "Sharp Beamer 123"
      @contract_for_camera = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool, :status => :submitted)
      @contract_for_camera_purpose = FactoryGirl.create :purpose, :description => "Benötige ich für die Aufnahmen meiner Abschlussarbeit."

      rand(3..5).times do
        FactoryGirl.create(:contract_line, :purpose => @contract_for_camera_purpose, :model => @camera_model, :contract => @contract_for_camera, :start_date => (Date.today + 7.days), :end_date => (Date.today + 10.days))
      end
      rand(3..5).times do
        FactoryGirl.create(:contract_line, :purpose => @contract_for_camera_purpose, :model => @tripod_model, :contract => @contract_for_camera, :start_date => (Date.today + 7.days), :end_date => (Date.today + 10.days))
      end

      # and some more random submitted contracts with lines
      rand(2..4).times do
        random_inventory_pool = @user.inventory_pools.sample
        random_contract = FactoryGirl.create(:contract, :user => @user, :inventory_pool => random_inventory_pool, :status => :submitted)
        purpose = FactoryGirl.create :purpose, description: Faker::Lorem.sentence
        rand(3..5).times do
          FactoryGirl.create(:contract_line, :contract => random_contract, :purpose => purpose)
        end
      end
    end
    
    def create_approved_contracts
      # approved_contract_1
      @approved_contract_1 = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool, :status => :approved)
      @approved_contract_1_purpose = FactoryGirl.create :purpose, :description => "Ersatzstativ für die Ausstellung."
      @approved_contract_1.contract_lines << FactoryGirl.create(:contract_line, :purpose => @approved_contract_1_purpose, :contract => @approved_contract_1, :model => @tripod_model)
      
      # approved_contract_2
      @approved_contract_2 = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool, :status => :approved)
      @approved_contract_2_purpose = FactoryGirl.create :purpose, :description => "Für das zweite Austellungswochenende."
      @approved_contract_2.contract_lines << FactoryGirl.create(:contract_line, :purpose => @approved_contract_2_purpose, :contract => @approved_contract_2, :model => @tripod_model)
      @approved_contract_2.contract_lines << FactoryGirl.create(:contract_line, :purpose => @approved_contract_2_purpose, :contract => @approved_contract_2, :model => @camera_model)

      # approved_contract_3
      @approved_contract_3 = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool, :status => :approved)
      @approved_contract_3_purpose = FactoryGirl.create :purpose, :description => "Für das dritte Austellungswochenende."
      @approved_contract_3.contract_lines << FactoryGirl.create(:contract_line, :purpose => @approved_contract_3_purpose, :contract => @approved_contract_3, :model => @tripod_model, :start_date => Date.today + 7.days, :end_date => Date.today + 8.days)

      # approved_contract_4
      @approved_contract_4 = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool, :status => :approved)
      @approved_contract_4_purpose = FactoryGirl.create :purpose, :description => "Für die Abschlussarbeit."
      @approved_contract_4.contract_lines << FactoryGirl.create(:contract_line, :purpose => @approved_contract_4_purpose, :contract => @approved_contract_4, :model => @beamer_model)
      @approved_contract_4.contract_lines << FactoryGirl.create(:contract_line, :purpose => @approved_contract_4_purpose, :contract => @approved_contract_4, :model => @beamer_model)
      @approved_contract_4.contract_lines << FactoryGirl.create(:contract_line, :purpose => @approved_contract_4_purpose, :contract => @approved_contract_4, :model => @beamer_model)

      # approved_contract_5
      @approved_contract_5 = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool, :status => :approved)
      @approved_contract_5_purpose = FactoryGirl.create :purpose, :description => "Ersatzstativ für die Ausstellung."
      @approved_contract_5.contract_lines << FactoryGirl.create(:contract_line, :purpose => @approved_contract_5_purpose, :contract => @approved_contract_5, :model => @camera_model)
      @approved_contract_5.contract_lines << FactoryGirl.create(:contract_line, :purpose => @approved_contract_5_purpose, :contract => @approved_contract_5, :model => @camera_model)
      @approved_contract_5.contract_lines << FactoryGirl.create(:contract_line, :purpose => @approved_contract_5_purpose, :contract => @approved_contract_5, :model => @tripod_model)
      @akku_aa = Option.find {|m| [m.name, m.product].include? "Akku AA" }
      @approved_contract_5.contract_lines << FactoryGirl.create(:option_line, :purpose => @approved_contract_5_purpose, :contract => @approved_contract_5, :option => @akku_aa, :quantity => 5)
    end
    
    def create_signed_contracts
      contract = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool, :status => :approved)
      purpose = FactoryGirl.create :purpose, :description => "Um meine Abschlussarbeit zu fotografieren."
      contract.contract_lines << FactoryGirl.create(:contract_line, :purpose => purpose, :contract => contract, :item_id => @inventory_pool.items.in_stock.where(:model_id => @camera_model).first.id, :model => @camera_model, :start_date => Date.yesterday, :end_date => Date.today)
      contract.sign(@pius)

      contract = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool, :status => :approved)
      purpose = FactoryGirl.create :purpose, :description => Faker::Lorem.sentence
      item = FactoryGirl.create(:item, :owner => @inventory_pool)
      contract.contract_lines << FactoryGirl.create(:contract_line, :purpose => purpose, :contract => contract, :item => item, model: item.model, :start_date => Date.yesterday, :end_date => Date.today)
      contract.sign(@pius)

      contract = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool_2, :status => :approved)
      purpose = FactoryGirl.create :purpose, :description => "Um meine Abschlussarbeit zu fotografieren."
      @arbitrary_model_1 = @inventory_pool_2.items.in_stock.first.model
      @arbitrary_model_2 = @inventory_pool_2.items.in_stock.last.model
      contract.contract_lines << FactoryGirl.create(:contract_line, :purpose => purpose, :contract => contract, :item_id => @inventory_pool_2.items.in_stock.where(:model_id => @arbitrary_model_1).first.id, :model => @arbitrary_model_1, :start_date => Date.yesterday, :end_date => Date.today)
      contract.contract_lines << FactoryGirl.create(:contract_line, :purpose => purpose, :contract => contract, :item_id => @inventory_pool_2.items.in_stock.where(:model_id => @arbitrary_model_2).first.id, :model => @arbitrary_model_2, :start_date => Date.yesterday, :end_date => Date.today, :returned_to_user => @pius, :returned_date => Date.today)
      contract.sign(@pius)

      contract = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool_2, :status => :approved)
      purpose = FactoryGirl.create :purpose, :description => "Um meine Abschlussarbeit zu fotografieren."
      contract.contract_lines << FactoryGirl.create(:contract_line, :purpose => purpose, :contract => contract, :item_id => @inventory_pool_2.items.in_stock.where(:model_id => @beamer_model).first.id, :model => @beamer_model, :start_date => Date.yesterday, :end_date => Date.today)
      contract.sign(@pius)
    end

    def create_closed_contracts
      contract = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool, :status => :approved)
      purpose = FactoryGirl.create :purpose, :description => Faker::Lorem.sentence
      item = FactoryGirl.create(:item, :owner => @inventory_pool)
      contract.contract_lines << FactoryGirl.create(:contract_line, :purpose => purpose, :contract => contract, :item => item, model: item.model, :start_date => Date.yesterday, :end_date => Date.today)
      contract.sign(@pius)
      contract.lines.each {|cl| cl.update_attributes(returned_date: Date.today, returned_to_user_id: @pius)}
      contract.close
    end

    def setup_groups
      @group_cast = Group.find_by_name("Cast")
      @group_cast.users << @user
      @group_cast.save
    end

    def lend_package
      contract = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool, :status => :approved)
      purpose = FactoryGirl.create :purpose, :description => "Paketausgabe"
      package_item =  @inventory_pool.items.detect{|i| i.children.size > 0}
      contract.contract_lines << FactoryGirl.create(:contract_line, :purpose => purpose, :contract => contract, :item_id => package_item.id, :model => package_item.model, :start_date => Date.yesterday, :end_date => Date.tomorrow)
      contract.sign(@pius)
    end
  end  
end
