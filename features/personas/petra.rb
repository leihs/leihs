# coding: UTF-8

# Persona:  Petra
# Job:      ZHDK Studentin
#

module Persona
  
  class Petra
    
    @@name = "Petra"
    @@lastname = "K."
    @@email = "petra@zhdk.ch"
    @@inventory_pool_name = "A-Ausleihe"
    
    def initialize
      setup_dependencies
      
      ActiveRecord::Base.transaction do 
        select_inventory_pool 
        create_user
        create_submitted_contracts
        create_overdue_hand_overs
        create_signed_contracts
      end
    end
    
    def setup_dependencies 
      Persona.create :ramon
      Persona.create :mike
      @pius = Persona.create :pius
    end

    def select_inventory_pool
      @inventory_pool = InventoryPool.find_by_name(@@inventory_pool_name)
    end
        
    def create_user
      @language = Language.find_by_locale_name "de-CH"
      @user = FactoryGirl.create(:user, :language => @language, :firstname => @@name, :lastname => @@lastname, :login => @@name.downcase, :email => @@email)
      @user.access_rights.create(:role => Role.find_by_name("customer"), :inventory_pool => @inventory_pool)
    end
    
    def create_submitted_contracts
      @purpose = FactoryGirl.create :purpose, :description => "Für meinen aktuellen Kurs."
      @camera_model = Model.find_by_name "Kamera Nikon X12"
      @tripod_model = Model.find_by_name "Kamera Stativ"
      @ultra_compact_model_model = Model.find_by_name "Ultra Compact Beamer"
      @contract_for_camera = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool, :status => :submitted)
      FactoryGirl.create(:contract_line, :purpose => @purpose, :model => @camera_model, :contract => @contract_for_camera, :start_date => (Date.today + 7.days), :end_date => (Date.today + 10.days))
      FactoryGirl.create(:contract_line, :purpose => @purpose, :model => @tripod_model, :contract => @contract_for_camera, :start_date => (Date.today + 7.days), :end_date => (Date.today + 10.days))
      FactoryGirl.create(:contract_line, :purpose => @purpose, :model => @tripod_model, :contract => @contract_for_camera, :start_date => (Date.today + 8.days), :end_date => (Date.today + 11.days))

      contract_for_ultra_compact_model = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool, :status => :submitted)
      FactoryGirl.create(:contract_line, :purpose => @purpose, :model => @ultra_compact_model_model, :contract => contract_for_ultra_compact_model, :start_date => (Date.today), :end_date => (Date.today + 1.days))
    end
    
    def create_overdue_hand_overs
      @beamer_model = Model.find_by_name "Sharp Beamer"
      @approved_contract_1 = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool, :status => :approved)
      @approved_contract_1_purpose = FactoryGirl.create :purpose, :description => "Ersatzstativ für die Ausstellung."
      FactoryGirl.create(:contract_line, :purpose => @approved_contract_1_purpose, :contract => @approved_contract_1, :model => @beamer_model, :start_date => Date.yesterday-1, :end_date => Date.today + 1)
      FactoryGirl.create(:contract_line, :purpose => @approved_contract_1_purpose, :contract => @approved_contract_1, :model => FactoryGirl.create(:model_with_items, inventory_pool: @inventory_pool), :start_date => Date.yesterday-1, :end_date => Date.today + 1)
    end
    
    def create_signed_contracts
      @approved_contract = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool, :status => :approved)
      purpose = FactoryGirl.create :purpose, :description => "Um meine Abschlussarbeit zu fotografieren."
      @approved_contract.contract_lines << FactoryGirl.create(:contract_line, :purpose => purpose, :contract => @approved_contract, :item_id => @inventory_pool.items.in_stock.where(:model_id => @beamer_model).first.id, :model => @beamer_model, :start_date => Date.yesterday, :end_date => Date.today)
      @akku = Option.find_by_name("Akku AA")
      @approved_contract.contract_lines << FactoryGirl.create(:option_line, :purpose => purpose, :contract => @approved_contract, :option => @akku, :start_date => Date.yesterday, :end_date => Date.today)
      @approved_contract.sign(@pius)
    end
  end  
end
