# coding: UTF-8

# Persona:  Ramon
# Job:      Leihs Developer and Administrator
#
require 'leihs_factory'

module Persona
  
  class Ramon
    
    NAME = "Ramon"
    LASTNAME = "C."
    PASSWORD = "password"
    EMAIL = "ramon@zhdk.ch"
    INVENTORY_POOL_NAME = "A-Ausleihe"
    
    def initialize
      ActiveRecord::Base.transaction do 
        create_minimal_setup
        create_admin_user
        create_inventory_pool
      end
    end
    
    def create_minimal_setup
      LeihsFactory.create_default_languages
      LeihsFactory.create_default_authentication_systems
      LeihsFactory.create_default_roles
      LeihsFactory.create_default_building
    end
    
    def create_admin_user
      @user = Factory(:user, :firstname => NAME, :lastname => LASTNAME, :login => NAME.downcase, :email => EMAIL)
      @user.access_rights.create(:role => Role.find_by_name("admin"))
      @database_authentication = Factory(:database_authentication, :user => @user, :password => PASSWORD)
    end
    
    def create_inventory_pool
      description = "Wichtige Hinweise...\n Bitte die Gegenstände rechtzeitig zurückbringen"
      contact_details = "A Verleih  /  ZHdK\nav@zh-dk.ch\n+41 00 00 00 00"
      Factory(:inventory_pool, :name => INVENTORY_POOL_NAME, :description => description, :contact_details => contact_details, :contract_description => "Gerät erhalten", :email => "av@zh-dk.ch", :shortname => "A")
    end

  end  
end
