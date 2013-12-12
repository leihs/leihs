# coding: UTF-8

# Persona:  Pius
# Job:      Inventory Pool Manager
#

module Persona

  class Pius

    @@name = "Pius"
    @@lastname = Faker::Lorem.word
    @@email = "pius@zhdk.ch"
    @@inventory_pool_name = "A-Ausleihe"

    def initialize
      setup_dependencies

      ActiveRecord::Base.transaction do
        create_lending_manager_user
        create_external_user
        create_user_with_large_hand_over
      end
    end

    def setup_dependencies 
      Persona.create :ramon
      Persona.create :mike
    end

    def create_lending_manager_user
      @language = Language.find_by_locale_name "de-CH"
      @user = FactoryGirl.create(:user, :language => @language, :firstname => @@name, :lastname => @@lastname, :login => @@name.downcase, :email => @@email)
      @inventory_pool = InventoryPool.find_by_name(@@inventory_pool_name)
      @user.access_rights.create(:role => Role.find_by_name("manager"), :inventory_pool => @inventory_pool, :access_level => 2)
    end

    def create_external_user
      @external_user = FactoryGirl.create(:user, :language => @language, :firstname => "Peter", :lastname => "Silie", :login => "peter", :email => "peter@silie.com")
      @external_user.access_rights.create(:role => Role.find_by_name("customer"), :inventory_pool => @inventory_pool)
    end

    def create_user_with_large_hand_over
      user = FactoryGirl.create :user
      approved_contract = FactoryGirl.create(:contract, :user => user, :inventory_pool => @inventory_pool, :status => :approved)
      approved_contract_purpose = FactoryGirl.create :purpose, :description => "Ersatzstativ für die Ausstellung."

      @inventory_pool.items.borrowable.select{|i| not i.current_borrower}.take(30).each do |i|
        approved_contract.contract_lines << FactoryGirl.create(:contract_line, :purpose => approved_contract_purpose, :contract => approved_contract, :model => i.model, :item => i)
      end
    end
  end
end
