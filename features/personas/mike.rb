# coding: UTF-8

# Persona:  Mike
# Job:      Inventory Manager
#

module Persona
  
  class Mike
    
    @@name = "Mike"
    @@lastname = "H."
    @@password = "password"
    @@email = "mike@zhdk.ch"
    @@inventory_pool_name = "A-Ausleihe"
    
    def initialize
      ActiveRecord::Base.transaction do 
        create_inventory_manager_user
        create_location_and_building
        create_minimal_inventory
      end
    end
    
    def create_inventory_manager_user
      @user = Factory(:user, :firstname => @@name, :lastname => @@lastname, :login => @@name.downcase, :email => @@email)
      @inventory_pool = InventoryPool.find_by_name(@@inventory_pool_name)
      @user.access_rights.create(:role => Role.find_by_name("manager"), :inventory_pool => @inventory_pool, :access_level => 3)
      @database_authentication = Factory(:database_authentication, :user => @user, :password => @@password)
    end
    
    def create_location_and_building
      @building = Factory(:building, :name => "Ausstellungsstrasse 60", :code => "AU60")
      @location = Factory(:location, :room => "UG 13", :shelf => "Ausgabe", :building => @building)
    end
    
    def create_minimal_inventory
      setup_beamer
      setup_camera
      setup_tripod
    end
    
    def setup_beamer
      @beamer_category = Factory(:category, :name => "Beamer")
      @beamer_model = Factory(:model, :name => "Sharp Beamer",
                                :manufacturer => "Sharp", 
                                :description => "Beamer, geeignet für alle Verwendungszwecke.", 
                                :hand_over_note => "Beamer brauch ein VGA Kabel!", 
                                :maintenance_period => 0)
      @beamer_model.model_links.create :model_group => @beamer_category
      @beamer_item = Factory(:item, :inventory_code => "beam123", :serial_number => "xyz456", :model => @beamer_model, :location => @location, :owner => @inventory_pool)
    end
    
    def setup_camera
      @camera_category = Factory(:category, :name => "Kameras")
      @camera_model = Factory(:model, :name => "Kamera Nikon X12",
                                :manufacturer => "Nikon", 
                                :description => "Super Kamera.", 
                                :hand_over_note => "Kamera brauch Akkus!", 
                                :maintenance_period => 0)
      @camera_model.model_links.create :model_group => @camera_category
      @camera_item = Factory(:item, :inventory_code => "cam123", :serial_number => "abc234", :model => @camera_model, :location => @location, :owner => @inventory_pool)
    end
    
    def setup_tripod
      @tripod_category = Factory(:category, :name => "Stative")
      @tripod_model = Factory(:model, :name => "Kamera Stativ",
                                :manufacturer => "Feli", 
                                :description => "Stabiles Kamera Stativ", 
                                :hand_over_note => "Stativ muss mit Stativtasche ausgehändigt werden.",
                                :maintenance_period => 0)
      @tripod_model.model_links.create :model_group => @tripod_category
      @tripod_item = Factory(:item, :inventory_code => "tri789", :serial_number => "fgh567", :model => @tripod_model, :location => @location, :owner => @inventory_pool)
    end

  end  
end
