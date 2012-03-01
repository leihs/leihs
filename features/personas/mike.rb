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
      setup_beamer
      setup_camera
    end
    
    def setup_beamer
      @beamer_category = Factory(:category, :name => "Beamer")
      @beamer = Factory(:model, :name => "Sharp Beamer",
                                :manufacturer => "Sharp", 
                                :description => "Beamer, geeignet für alle Verwendungszwecke.", 
                                :hand_over_note => "Beamer brauch ein VGA Kabel!", 
                                :maintance_period => 0)
      @beamer.model_links.create :model_group => @beamer_category
    end
    
    def setup_camera
      @camera_category = Factory(:category, :name => "Cameras")
      @camera = Factory(:model, :name => "Kamera Nikon X12",
                                :manufacturer => "Nikon", 
                                :description => "Super Kamera.", 
                                :hand_over_note => "Kamera brauch Akkus!", 
                                :maintance_period => 0)
      @camera.model_links.create :model_group => @camera_category
    end

  end  
end
