# coding: UTF-8

# Persona:  Matti
# Job:      Inventory Manager
#

module Persona
  
  class Matti
    
    @@name = "Matti"
    @@lastname = "S."
    @@email = "matti@zhdk.ch"
    @@inventory_pool_name = "IT-Ausleihe"
    
    def initialize
      setup_dependencies
      
      ActiveRecord::Base.transaction do 
        create_inventory_manager_user
        create_location_and_building
        create_minimal_inventory
      end
    end
    
    def setup_dependencies 
      Persona.create :ramon
    end
    
    def create_inventory_manager_user
      @language = Language.find_by_locale_name "de-CH"
      @user = FactoryGirl.create(:user, :language => @language, :firstname => @@name, :lastname => @@lastname, :login => @@name.downcase, :email => @@email)
      @inventory_pool = InventoryPool.find_by_name(@@inventory_pool_name)
      @user.access_rights.create(:role => :inventory_manager, :inventory_pool => @inventory_pool)
    end
    
    def create_location_and_building
      @building = FactoryGirl.create(:building, :name => "Ausstellungsstrasse 60", :code => "AU60")
      @location = FactoryGirl.create(:location, :room => "SQ2", :shelf => "Desk", :building => @building)
    end
    
    def create_minimal_inventory
      setup_notebooks
    end
    
    def setup_notebooks
      @notebook_model = FactoryGirl.create(:model, :product => "MacBookPro",
                                :manufacturer => "Apple", 
                                :description => "Laptop für Studis und Angestellte.", 
                                :hand_over_note => "Mit Verpackung aushändigen.", 
                                :maintenance_period => 0)
      @notebook_model.model_links.create :model_group => @notebook_category
      @notebook_item_1 = FactoryGirl.create(:item, :inventory_code => "book1", :serial_number => "book1", :model => @notebook_model, :location => @location, :owner => @inventory_pool)
      @notebook_item_2 = FactoryGirl.create(:item, :inventory_code => "book2", :serial_number => "book2", :model => @notebook_model, :location => @location, :owner => @inventory_pool)
    end
  end  
end
