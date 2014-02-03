# coding: UTF-8

# Persona:  Pius
# Job:      Inventory Pool Manager
#

module Persona

  class Andi

    @@name = "Andi"
    @@lastname = Faker::Lorem.word
    @@email = "andi@zhdk.ch"
    @@inventory_pool_names = ["A-Ausleihe", "IT-Ausleihe", "AV-Technik"]

    def initialize
      setup_dependencies

      ActiveRecord::Base.transaction do
        create_group_managers
        create_verify_groups
        create_users_with_orders_to_be_verified
        create_unapprovable_order_to_be_verified
        create_group_users_with_orders
      end
    end

    def setup_dependencies 
      Persona.create :ramon
      Persona.create :mike
    end

    def create_group_managers
      @language = Language.find_by_locale_name "de-CH"
      @user = FactoryGirl.create(:user, :language => @language, :firstname => @@name, :lastname => @@lastname, :login => @@name.downcase, :email => @@email)
      @inventory_pool_1 = InventoryPool.find_by_name(@@inventory_pool_names.first)
      @inventory_pool_2 = InventoryPool.find_by_name(@@inventory_pool_names.second)
      @inventory_pool_3 = InventoryPool.find_by_name(@@inventory_pool_names.third)
      @user.access_rights.create(:role => :group_manager, :inventory_pool => @inventory_pool_1)
      @user.access_rights.create(:role => :group_manager, :inventory_pool => @inventory_pool_2)
      @user.access_rights.create(:role => :group_manager, :inventory_pool => @inventory_pool_3)

      # create an additional group manager
      user = FactoryGirl.create :user, language: @language
      user.access_rights.create(:role => :group_manager, :inventory_pool => @inventory_pool_1)
    end

    def create_verify_groups
      @verify_group_1 = FactoryGirl.create(:group, :name => "FFI", :inventory_pool => @inventory_pool_1, :is_verification_required => true)
      @verify_group_2 = FactoryGirl.create(:group, :name => "VTO", :inventory_pool => @inventory_pool_1, :is_verification_required => true)
      @verify_group_3 = FactoryGirl.create(:group, :name => "1. Semester", :inventory_pool => @inventory_pool_2, :is_verification_required => true)
    end

    def create_users_with_orders_to_be_verified

      # #############################
      # order with one model from one verify group (different status) =============
      # #############################

      user_1 = FactoryGirl.create :user
      user_1.access_rights.create(:role => :customer, :inventory_pool => @inventory_pool_1)
      @verify_group_1.users << user_1
      @verify_group_2.users << user_1

      date_range = (Date.today - 1.week..Date.today)

      [:submitted, :approved, :rejected].each do |status|

        order_to_verify_1 = FactoryGirl.create(:contract, :user => user_1, :inventory_pool => @inventory_pool_1, :status => status, :created_at => rand(date_range) + 12.hours)
        order_to_verify_1_purpose = FactoryGirl.create :purpose, :description => "Ersatzstativ für die Ausstellung."

        rand(3..5).times do
          item = FactoryGirl.create :item, inventory_pool: @inventory_pool_1
          order_to_verify_1.contract_lines << FactoryGirl.create(:contract_line, :purpose => order_to_verify_1_purpose, :contract => order_to_verify_1, :model => item.model)
        end

        model_1 = FactoryGirl.create :model_with_items, inventory_pool: @inventory_pool_1
        model_1.partitions << Partition.create(model_id: model_1.id,
                                               inventory_pool_id: @inventory_pool_1.id,
                                               group_id: @verify_group_1.id,
                                               quantity: 1)
        order_to_verify_1.contract_lines << FactoryGirl.create(:contract_line, :purpose => order_to_verify_1_purpose, :contract => order_to_verify_1, :model => model_1)

      end

      order_to_verify_2 = FactoryGirl.create(:contract, :user => user_1, :inventory_pool => @inventory_pool_1, :status => :submitted, :created_at => rand(date_range) + 12.hours)
      order_to_verify_2_purpose = FactoryGirl.create :purpose, :description => "Ersatzstativ für die Ausstellung."

      rand(3..5).times do
        item = FactoryGirl.create :item, inventory_pool: @inventory_pool_1
        order_to_verify_2.contract_lines << FactoryGirl.create(:contract_line, :purpose => order_to_verify_2_purpose, :contract => order_to_verify_2, :model => item.model)
      end

      # ########################
      # order with one model from two verify groups from the same inventory pool =============
      ##########################

      order_to_verify_3 = FactoryGirl.create(:contract, :user => user_1, :inventory_pool => @inventory_pool_1, :status => :submitted, :created_at => rand(date_range) + 12.hours)
      order_to_verify_3_purpose = FactoryGirl.create :purpose, :description => "Ersatzstativ für die Ausstellung."

      rand(3..5).times do
        item = FactoryGirl.create :item, inventory_pool: @inventory_pool_1
        order_to_verify_3.contract_lines << FactoryGirl.create(:contract_line, :purpose => order_to_verify_3_purpose, :contract => order_to_verify_3, :model => item.model)
      end

      model_2 = FactoryGirl.create :model_with_items, inventory_pool: @inventory_pool_1
      model_2.partitions << Partition.create(model_id: model_2.id,
                                             inventory_pool_id: @inventory_pool_1.id,
                                             group_id: @verify_group_2.id,
                                             quantity: 1)
      2.times do
        order_to_verify_3.contract_lines << FactoryGirl.create(:contract_line, :purpose => order_to_verify_3_purpose, :contract => order_to_verify_3, :model => model_2)
      end
    end

    def create_unapprovable_order_to_be_verified
      # order with one model from one verify group =============
      user_1 = FactoryGirl.create :user
      user_1.access_rights.create(:role => :customer, :inventory_pool => @inventory_pool_1, suspended_until: Date.today, suspended_reason: "suspreason")
      @verify_group_1.users << user_1

      order_to_verify_1 = FactoryGirl.create(:contract, :user => user_1, :inventory_pool => @inventory_pool_1, :status => :submitted)
      order_to_verify_1_purpose = FactoryGirl.create :purpose, :description => "Ersatzstativ für die Ausstellung."

      rand(3..5).times do
        item = FactoryGirl.create :item, inventory_pool: @inventory_pool_1
        order_to_verify_1.contract_lines << FactoryGirl.create(:contract_line, :purpose => order_to_verify_1_purpose, :contract => order_to_verify_1, :model => item.model)
      end

      model_1 = FactoryGirl.create :model_with_items, inventory_pool: @inventory_pool_1
      model_1.partitions << Partition.create(model_id: model_1.id,
                                             inventory_pool_id: @inventory_pool_1.id,
                                             group_id: @verify_group_1.id,
                                             quantity: 1)
      order_to_verify_1.contract_lines << FactoryGirl.create(:contract_line, :purpose => order_to_verify_1_purpose, :contract => order_to_verify_1, :model => model_1)
    end

    def create_group_users_with_orders

      # one user from two groups from same inventory pool
      user_1 = FactoryGirl.create :user
      user_1.access_rights.create(:role => :customer, :inventory_pool => @inventory_pool_1)
      @verify_group_1.users << user_1
      @verify_group_2.users << user_1

      order_to_verify_1 = FactoryGirl.create(:contract, :user => user_1, :inventory_pool => @inventory_pool_1, :status => :submitted)
      order_to_verify_1_purpose = FactoryGirl.create :purpose, :description => "Ersatzstativ für die Ausstellung."

      rand(3..5).times do
        item = FactoryGirl.create :item, inventory_pool: @inventory_pool_1
        order_to_verify_1.contract_lines << FactoryGirl.create(:contract_line, :purpose => order_to_verify_1_purpose, :contract => order_to_verify_1, :model => item.model)
      end

      # one user from two groups from two inventory pool
      user_2 = FactoryGirl.create :user
      user_2.access_rights.create(:role => :customer, :inventory_pool => @inventory_pool_1)
      @verify_group_1.users << user_2
      @verify_group_3.users << user_2

      order_to_verify_1 = FactoryGirl.create(:contract, :user => user_2, :inventory_pool => @inventory_pool_1, :status => :submitted)
      order_to_verify_1_purpose = FactoryGirl.create :purpose, :description => "Ersatzstativ für die Ausstellung."

      rand(3..5).times do
        item = FactoryGirl.create :item, inventory_pool: @inventory_pool_1
        order_to_verify_1.contract_lines << FactoryGirl.create(:contract_line, :purpose => order_to_verify_1_purpose, :contract => order_to_verify_1, :model => item.model)
      end

      # one user from one group from same inventory pool
      user_3 = FactoryGirl.create :user
      user_3.access_rights.create(:role => :customer, :inventory_pool => @inventory_pool_1)
      @verify_group_1.users << user_3

      order_to_verify_1 = FactoryGirl.create(:contract, :user => user_3, :inventory_pool => @inventory_pool_1, :status => :submitted)
      order_to_verify_1_purpose = FactoryGirl.create :purpose, :description => "Ersatzstativ für die Ausstellung."

      rand(3..5).times do
        item = FactoryGirl.create :item, inventory_pool: @inventory_pool_1
        order_to_verify_1.contract_lines << FactoryGirl.create(:contract_line, :purpose => order_to_verify_1_purpose, :contract => order_to_verify_1, :model => item.model)
      end

    end

  end
end
