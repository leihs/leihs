# coding: UTF-8

# Persona:  Assist Ant
# Job:      Lending assistant
#

module Persona
  
  class Assist
    
    @@name = "Assist"
    @@lastname = "Ant"
    @@email = "assist.ant@zhdk.ch"
    @@inventory_pool_name = "A-Ausleihe"
    
    def initialize
      setup_dependencies
      
      ActiveRecord::Base.transaction do 
        select_inventory_pool 
        create_user
      end
    end
    
    def setup_dependencies 
      Persona.create :ramon
    end

    def select_inventory_pool
      @inventory_pool = InventoryPool.find_by_name(@@inventory_pool_name)
    end
        
    def create_user
      @language = Language.find_by_locale_name "de-CH"
      @user = FactoryGirl.create(:user, :language => @language, :firstname => @@name, :lastname => @@lastname, :login => @@name.downcase, :email => @@email)
      @user.access_rights.create(:role => Role.find_by_name("manager"), :inventory_pool => @inventory_pool, :access_level => 1)
    end

  end  
end
