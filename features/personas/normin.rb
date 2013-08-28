# coding: UTF-8

# Persona:  Normin
# Job:      ZHDK Student
#

module Persona
  
  class Normin
    
    @@name = "Normin"
    @@lastname = "N."
    @@password = "password"
    @@email = "normin@zhdk.ch"
    @@inventory_pool_names = ["A-Ausleihe", "IT-Ausleihe", "AV-Technik"]
    
    def initialize
      setup_dependencies
      
      ActiveRecord::Base.transaction do
        select_inventory_pool 
        create_user
        setup_groups
        create_orders
        create_unsigned_contracts
        create_signed_contracts
        lend_package
      end
    end
    
    def setup_dependencies 
      Persona.create :ramon
      Persona.create :mike
      @pius = Persona.create :pius
    end

    def select_inventory_pool 
      @inventory_pool = InventoryPool.find_by_name(@@inventory_pool_names.first)
      @inventory_pool_2 = InventoryPool.find_by_name(@@inventory_pool_names.second)
    end
    
    def create_user
      @language = Language.find_by_locale_name "de-CH"
      @user = FactoryGirl.create(:user, :language => @language, :firstname => @@name, :lastname => @@lastname, :login => @@name.downcase, :email => @@email)
      @@inventory_pool_names.each { |ip_name| @user.access_rights.create(:role => Role.find_by_name("customer"), :inventory_pool => InventoryPool.find_by_name(ip_name)) }

      # create deactivated access right
      @user.access_rights.create(:role => Role.find_by_name("customer"), :inventory_pool => InventoryPool.last, :deleted_at => Date.yesterday)

      @database_authentication = FactoryGirl.create(:database_authentication, :user => @user, :password => @@password)
    end
    
    def create_orders
      @camera_model = Model.find_by_name "Kamera Nikon X12"
      @tripod_model = Model.find_by_name "Kamera Stativ"
      @order_for_camera = FactoryGirl.create(:order, :user => @user, :inventory_pool => @inventory_pool, :status_const => Order::SUBMITTED)
      @order_for_camera_purpose = FactoryGirl.create :purpose, :description => "Benötige ich für die Aufnahmen meiner Abschlussarbeit."
      @order_line_camera = FactoryGirl.create(:order_line, :purpose => @order_for_camera_purpose, :inventory_pool => @inventory_pool, :model => @camera_model, :order => @order_for_camera, :start_date => (Date.today + 7.days), :end_date => (Date.today + 10.days))
      @order_line_tripod = FactoryGirl.create(:order_line, :purpose => @order_for_camera_purpose, :inventory_pool => @inventory_pool, :model => @tripod_model, :order => @order_for_camera, :start_date => (Date.today + 7.days), :end_date => (Date.today + 10.days))
    end
    
    def create_unsigned_contracts
      # unsigned_contract_1
      @unsigned_contract_1 = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool)
      @unsigned_contract_1_purpose = FactoryGirl.create :purpose, :description => "Ersatzstativ für die Ausstellung."
      FactoryGirl.create(:contract_line, :purpose => @unsigned_contract_1_purpose, :contract => @unsigned_contract_1, :model => @tripod_model)
      
      # unsigned_contract_2
      @unsigned_contract_2 = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool)
      @unsigned_contract_2_purpose = FactoryGirl.create :purpose, :description => "Für das zweite Austellungswochenende."
      FactoryGirl.create(:contract_line, :purpose => @unsigned_contract_2_purpose, :contract => @unsigned_contract_2, :model => @tripod_model)
      FactoryGirl.create(:contract_line, :purpose => @unsigned_contract_2_purpose, :contract => @unsigned_contract_2, :model => @camera_model)

      # unsigned_contract_3
      @unsigned_contract_3 = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool)
      @unsigned_contract_3_purpose = FactoryGirl.create :purpose, :description => "Für das dritte Austellungswochenende."
      FactoryGirl.create(:contract_line, :purpose => @unsigned_contract_3_purpose, :contract => @unsigned_contract_3, :model => @tripod_model, :start_date => Date.today + 7.days, :end_date => Date.today + 8.days)
      FactoryGirl.create(:contract_line, :purpose => @unsigned_contract_3_purpose, :contract => @unsigned_contract_3, :model => @camera_model, :start_date => Date.today + 7.days, :end_date => Date.today + 8.days)
    end
    
    def create_signed_contracts
      @unsigned_contract = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool)
      purpose = FactoryGirl.create :purpose, :description => "Um meine Abschlussarbeit zu fotografieren."
      FactoryGirl.create(:contract_line, :purpose => purpose, :contract => @unsigned_contract, :item_id => @inventory_pool.items.in_stock.where(:model_id => @camera_model).first.id, :model => @camera_model, :start_date => Date.yesterday, :end_date => Date.today)
      @unsigned_contract.sign(@pius)

      @unsigned_contract_2 = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool_2)
      purpose = FactoryGirl.create :purpose, :description => "Um meine Abschlussarbeit zu fotografieren."
      @arbitrary_model_1 = @inventory_pool_2.items.in_stock.first.model
      @arbitrary_model_2 = @inventory_pool_2.items.in_stock.last.model
      FactoryGirl.create(:contract_line, :purpose => purpose, :contract => @unsigned_contract_2, :item_id => @inventory_pool_2.items.in_stock.where(:model_id => @arbitrary_model_1).first.id, :model => @arbitrary_model_1, :start_date => Date.yesterday, :end_date => Date.today)
      FactoryGirl.create(:contract_line, :purpose => purpose, :contract => @unsigned_contract_2, :item_id => @inventory_pool_2.items.in_stock.where(:model_id => @arbitrary_model_2).first.id, :model => @arbitrary_model_2, :start_date => Date.yesterday, :end_date => Date.today)
      @unsigned_contract_2.sign(@pius)
    end

    def setup_groups
      @group_cast = Group.find_by_name("Cast")
      @group_cast.users << @user
      @group_cast.save
    end

    def lend_package
      contract = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool)
      purpose = FactoryGirl.create :purpose, :description => "Paketausgabe"
      package_item =  @inventory_pool.items.detect{|i| i.children.size > 0}
      FactoryGirl.create(:contract_line, :purpose => purpose, :contract => contract, :item_id => package_item.id, :model => package_item.model, :start_date => Date.yesterday, :end_date => Date.tomorrow)
      contract.sign(@pius)
    end
  end  
end
