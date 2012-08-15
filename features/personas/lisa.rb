# coding: UTF-8

# Persona:  Lisa
# Job:      ZHDK Dozentin
#

module Persona
  
  class Lisa
    
    @@name = "Lisa"
    @@lastname = "L."
    @@password = "password"
    @@email = "lisa@zhdk.ch"
    @@inventory_pool_name = "A-Ausleihe"
    
    def initialize
      setup_dependencies
      
      ActiveRecord::Base.transaction do 
        select_inventory_pool 
        create_user
        create_orders
        create_overbooking
      end
    end
    
    def setup_dependencies 
      Persona.create :ramon
      Persona.create :mike
      # lisa has to be create after normin and petra because she is overbooking things
      Persona.create :normin
      Persona.create :petra
      @pius = Persona.create :pius
    end

    def select_inventory_pool
      @inventory_pool = InventoryPool.find_by_name(@@inventory_pool_name)
    end
        
    def create_user
      @user = FactoryGirl.create(:user, :firstname => @@name, :lastname => @@lastname, :login => @@name.downcase, :email => @@email)
      @user.access_rights.create(:role => Role.find_by_name("customer"), :inventory_pool => @inventory_pool)
      @database_authentication = FactoryGirl.create(:database_authentication, :user => @user, :password => @@password)
    end
    
    def create_orders
      @camera_model = Model.find_by_name "Kamera Nikon X12"
      @order_for_camera = FactoryGirl.create(:order, :user => @user, :inventory_pool => @inventory_pool, :status_const => Order::SUBMITTED)
      @order_for_camera_purpose = FactoryGirl.create :purpose, :description => "Fotoshooting (Kurs Fotografie)."
      @order_line_camera = FactoryGirl.create(:order_line, :purpose => @order_for_camera_purpose, :inventory_pool => @inventory_pool, :model => @camera_model, :order => @order_for_camera, :start_date => (Date.today + 37.days), :end_date => (Date.today + 45.days))
    end

    def create_overbooking
      @model = @inventory_pool.models.first
      availabilities = @model.availability_in @inventory_pool
      start_date = availabilities.changes.first.first
      quantity = 1 + availabilities.changes.first.second[nil][:in_quantity]
      @unsigned_contract_1 = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool)
      @unsigned_contract_1_purpose = FactoryGirl.create :purpose, :description => "Ganz dringend benötigt für meine Abschlussarbeit."
      FactoryGirl.create(:contract_line, :purpose => @unsigned_contract_1_purpose, :contract => @unsigned_contract_1, :model => @model, :quantity => quantity)
    end
  end  
end
