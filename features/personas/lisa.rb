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
        create_submitted_contracts
        create_submitted_contract_with_problems
        create_overbooking
        create_overdued_take_back
        setup_groups
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
      @language = Language.find_by_locale_name "de-CH"
      @user = FactoryGirl.create(:user, :language => @language, :firstname => @@name, :lastname => @@lastname, :login => @@name.downcase, :email => @@email)
      @user.access_rights.create(:role => Role.find_by_name("customer"), :inventory_pool => @inventory_pool)
      @database_authentication = FactoryGirl.create(:database_authentication, :user => @user, :password => @@password)
    end
    
    def create_submitted_contracts
      @camera_model = Model.find_by_name "Kamera Nikon X12"
      @contract_for_camera = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool, :status => :submitted)
      purpose = FactoryGirl.create :purpose, :description => "Fotoshooting (Kurs Fotografie)."
      FactoryGirl.create(:contract_line, :purpose => purpose, :model => @camera_model, :contract => @contract_for_camera, :start_date => (Date.today + 37.days), :end_date => (Date.today + 45.days))
    end

    def create_submitted_contract_with_problems
      @contract_with_problems = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool, :status => :submitted)
      purpose = FactoryGirl.create :purpose, :description => "Brauche ich zwingend für meinen Kurs."
      (@camera_model.borrowable_items.size + 1).times do 
        FactoryGirl.create(:contract_line, :purpose => purpose, :quantity => 1, :model => @camera_model, :contract => @contract_with_problems, :start_date => (Date.today + 52.days), :end_date => (Date.today + 55.days))
      end
    end

    def create_overbooking
      @model = @inventory_pool.models.first
      availabilities = @model.availability_in @inventory_pool
      start_date = availabilities.changes.first.first
      quantity = 1 + availabilities.changes.first.second[nil][:in_quantity]
      @approved_contract_1 = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool, :status => :approved)
      @approved_contract_1_purpose = FactoryGirl.create :purpose, :description => "Ganz dringend benötigt für meine Abschlussarbeit."
      quantity.times do 
        FactoryGirl.create(:contract_line, :purpose => @approved_contract_1_purpose, :contract => @approved_contract_1, :model => @model)
      end
    end

    def create_overdued_take_back
      back_to_the_future(Date.today - 5.days)
      @overdued_contract = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool, :status => :approved)
      purpose = FactoryGirl.create :purpose, :description => "Als Ersatz."
      @tripod_model = Model.find_by_name "Kamera Stativ"
      @overdued_contract.contract_lines << FactoryGirl.create(:contract_line, :purpose => purpose, :contract => @overdued_contract,
                                                              :item_id => @inventory_pool.items.in_stock.where(:model_id => @tripod_model.id).first.id,
                                                              :model => @tripod_model, :start_date => Date.today, :end_date => (Date.today + 4.days))
      @overdued_contract.sign(@pius)
      back_to_the_present
    end

    def setup_groups
      @group_cast = Group.find_by_name("Cast")
      @group_cast.users << @user
      @group_cast.save
    end
  end  
end
