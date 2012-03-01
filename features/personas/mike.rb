# coding: UTF-8

# Persona:  Mike
# Job:      Inventory Manager
#
require 'factory'

module Persona
  
  class Mike
    
    NAME = "Mike"
    LASTNAME = "H."
    PASSWORD = "password"
    EMAIL = "mike@zh-dk.ch"
    INVENTORY_POOL_NAME = "A-Ausleihe"
    
    def initialize
      ActiveRecord::Base.transaction do 
        create_inventory_manager_user
        setup_minimal_inventory
      end
    end
    
    def create_inventory_manager_user
      @user = Factory(:user, :firstname => NAME, :lastname => LASTNAME, :login => NAME.downcase, :email => EMAIL)
      @inventory_pool = InventoryPool.find_by_name(INVENTORY_POOL_NAME)
      @user.access_rights.create(:role => Role.find_by_name("manager"), :inventory_pool => @inventory_pool, :access_level => 3)
      @database_authentication = Factory(:database_authentication, :user => @user, :password => PASSWORD)
    end
    
    def create_minimal_inventory
      
    end

  end  
end
