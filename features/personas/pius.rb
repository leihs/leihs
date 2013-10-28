# coding: UTF-8

# Persona:  Pius
# Job:      Inventory Pool Manager
#

module Persona
  
  class Pius
    
    @@name = "Pius"
    @@lastname = Faker::Lorem.word
    @@password = "password"
    @@email = "pius@zhdk.ch"
    @@inventory_pool_name = "A-Ausleihe"
    
    def initialize
      setup_dependencies
      
      ActiveRecord::Base.transaction do
        create_lending_manager_user
        create_external_user
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
      @database_authentication = FactoryGirl.create(:database_authentication, :user => @user, :password => @@password)
    end

    def create_external_user
      @external_user = FactoryGirl.create(:user, :language => @language, :firstname => "Peter", :lastname => "Silie", :login => "peter", :email => "peter@silie.com")
      @external_user.access_rights.create(:role => Role.find_by_name("customer"), :inventory_pool => @inventory_pool)
    end
  end  
end
