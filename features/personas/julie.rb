# coding: UTF-8

# Persona:  Julie
# Job:      Delegator customer
#

module Persona

  class Julie

    @@name = "Julie"
    @@lastname = Faker::Name.last_name
    @@email = "julie@zhdk.ch"
    @@inventory_pool_name = "A-Ausleihe"

    def initialize
      setup_dependencies

      ActiveRecord::Base.transaction do
        select_inventory_pool
        create_user
        create_delegations
        create_submitted_contracts
        create_approved_contracts
        create_signed_contracts
        create_overdue_signed_contracts
      end
    end

    def setup_dependencies 
      @pius = Persona.create :pius
      @mina = Persona.create :mina
    end

    def select_inventory_pool
      @inventory_pool = InventoryPool.find_by_name(@@inventory_pool_name)
    end

    def create_user
      @julie = FactoryGirl.create(:user, firstname: @@name, lastname: @@lastname, login: @@name.downcase, email: @@email)
      @julie.access_rights.create(:role => :customer, :inventory_pool => @inventory_pool)
    end

    def create_delegations
      @delegation1 = FactoryGirl.create(:user,
                                        delegator_user: @julie,
                                        firstname: Faker::Lorem.sentence,
                                        lastname: nil,
                                        login: nil,
                                        phone: nil,
                                        authentication_system: nil,
                                        unique_id: nil,
                                        email: nil,
                                        badge_id: nil,
                                        address: nil,
                                        city: nil,
                                        country: nil,
                                        zip: nil,
                                        language: nil)
      @delegation1.delegated_users << @mina
      @delegation1.access_rights.create(:role => :customer, :inventory_pool => @inventory_pool)

      @delegation2 = FactoryGirl.create(:user,
                                        delegator_user: @mina,
                                        firstname: Faker::Lorem.sentence,
                                        lastname: nil,
                                        login: nil,
                                        phone: nil,
                                        authentication_system: nil,
                                        unique_id: nil,
                                        email: nil,
                                        badge_id: nil,
                                        address: nil,
                                        city: nil,
                                        country: nil,
                                        zip: nil,
                                        language: nil)
      @delegation2.delegated_users << @julie
      @delegation2.access_rights.create(:role => :customer, :inventory_pool => @inventory_pool)

      # delegation without access rights
      @delegation3 = FactoryGirl.create(:user,
                                        delegator_user: @mina,
                                        firstname: Faker::Lorem.sentence,
                                        lastname: nil,
                                        login: nil,
                                        phone: nil,
                                        authentication_system: nil,
                                        unique_id: nil,
                                        email: nil,
                                        badge_id: nil,
                                        address: nil,
                                        city: nil,
                                        country: nil,
                                        zip: nil,
                                        language: nil)
      @delegation3.delegated_users << @julie

      # delegation with access rights to more pools
      @delegation4 = FactoryGirl.create(:user,
                                        delegator_user: @mina,
                                        firstname: Faker::Lorem.sentence,
                                        lastname: nil,
                                        login: nil,
                                        phone: nil,
                                        authentication_system: nil,
                                        unique_id: nil,
                                        email: nil,
                                        badge_id: nil,
                                        address: nil,
                                        city: nil,
                                        country: nil,
                                        zip: nil,
                                        language: nil)
      @delegation4.delegated_users << @julie
      @delegation4.access_rights.create(:role => :customer, :inventory_pool => @inventory_pool)
      rand(1..3).times do
        ip = FactoryGirl.create(:inventory_pool)
        @delegation4.access_rights.create(:role => :customer, :inventory_pool => ip)
        ip.items << FactoryGirl.create(:item)
      end
    end

    def create_submitted_contracts
      contract = FactoryGirl.create(:contract, :user => @delegation1, :delegated_user => @mina, :inventory_pool => @inventory_pool, :status => :submitted)
      contract_purpose = FactoryGirl.create :purpose, :description => Faker::Lorem.sentence

      rand(3..5).times do
        item = FactoryGirl.create :item, inventory_pool: @inventory_pool
        contract.contract_lines << FactoryGirl.create(:contract_line, :purpose => contract_purpose, :contract => contract, :model => item.model)
      end
    end

    def create_approved_contracts
      contract = FactoryGirl.create(:contract, :user => @delegation1, :delegated_user => @julie, :inventory_pool => @inventory_pool, :status => :approved)
      contract_purpose = FactoryGirl.create :purpose, :description => Faker::Lorem.sentence

      rand(3..5).times do
        item = FactoryGirl.create :item, inventory_pool: @inventory_pool
        contract.contract_lines << FactoryGirl.create(:contract_line, :purpose => contract_purpose, :contract => contract, :model => item.model, :item => item)
      end
    end

    def create_signed_contracts
      contract = FactoryGirl.create(:contract, :user => @delegation1, :delegated_user => @mina, :inventory_pool => @inventory_pool, :status => :approved)
      contract_purpose = FactoryGirl.create :purpose, :description => Faker::Lorem.sentence

      rand(3..5).times do
        item = FactoryGirl.create :item, inventory_pool: @inventory_pool
        contract.contract_lines << FactoryGirl.create(:contract_line, purpose: contract_purpose, contract: contract, model: item.model, item: item, start_date: Date.today)
      end

      contract.reload.sign @pius
    end

    def create_overdue_signed_contracts
      back_to_the_future(Date.today - 5.days)
      create_signed_contracts
      back_to_the_present
    end

  end

end
