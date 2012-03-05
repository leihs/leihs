# coding: UTF-8

# Persona:  Normin
# Job:      ZHDK Student
#
require 'factory'

module Persona
  
  class Normin
    
    NAME = "Normin"
    LASTNAME = "N."
    PASSWORD = "password"
    EMAIL = "normin@zhdk.ch"
    INVENTORY_POOL_NAME = "A-Ausleihe"
    
    def initialize
      ActiveRecord::Base.transaction do 
        create_user
        create_order
      end
    end
    
    def create_user
      @user = Factory(:user, :firstname => NAME, :lastname => LASTNAME, :login => NAME.downcase, :email => EMAIL)
      @inventory_pool = InventoryPool.find_by_name(INVENTORY_POOL_NAME)
      @user.access_rights.create(:role => Role.find_by_name("customer"), :inventory_pool => @inventory_pool)
      @database_authentication = Factory(:database_authentication, :user => @user, :password => PASSWORD)
    end
    
    def create_order
      @inventory_pool = InventoryPool.find_by_name(INVENTORY_POOL_NAME)
      @camera_model = Model.find_by_name "Kamera Nikon X12"
      @order_for_camera = Factory(:order, :user => @user, :inventory_pool => @inventory_pool, :status_const => 1)
      @order_line_camera = Factory(:order_line, :inventory_pool => @inventory_pool, :model => @camera_model, :order => @order_for_camera)
    end
  end  
end
