# coding: UTF-8

# Persona:  Normin
# Job:      ZHDK Student
#
require 'factory'

module Persona
  
  class Normin
    
    @@name = "Normin"
    @@lastname = "N."
    @@password = "password"
    @@email = "normin@zhdk.ch"
    @@inventory_pool_name = "A-Ausleihe"
    
    def initialize
      ActiveRecord::Base.transaction do 
        create_user
        create_order
      end
    end
    
    def create_user
      @user = Factory(:user, :firstname => @@name, :lastname => @@lastname, :login => @@name.downcase, :email => @@email)
      @inventory_pool = InventoryPool.find_by_name(@@inventory_pool_name)
      @user.access_rights.create(:role => Role.find_by_name("customer"), :inventory_pool => @inventory_pool)
      @database_authentication = Factory(:database_authentication, :user => @user, :password => @@password)
    end
    
    def create_order
      @inventory_pool = InventoryPool.find_by_name(@@inventory_pool_name)
      @camera_model = Model.find_by_name "Kamera Nikon X12"
      @order_for_camera = Factory(:order, :user => @user, :inventory_pool => @inventory_pool, :status_const => 1)
      @order_line_camera = Factory(:order_line, :inventory_pool => @inventory_pool, :model => @camera_model, :order => @order_for_camera)
    end
  end  
end
