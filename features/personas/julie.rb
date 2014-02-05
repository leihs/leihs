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
        create_signed_contracts
      end
    end

    def setup_dependencies 
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
      @delegation1.users << @mina
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
      @delegation2.users << @julie
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
      @delegation3.users << @julie
    end

    def create_submitted_contracts
      contract = FactoryGirl.create(:contract, :user => @delegation1, :delegated_user => @julie, :inventory_pool => @inventory_pool, :status => :submitted)
      contract_purpose = FactoryGirl.create :purpose, :description => Faker::Lorem.sentence

      rand(3..5).times do
        item = FactoryGirl.create :item, inventory_pool: @inventory_pool
        contract.contract_lines << FactoryGirl.create(:contract_line, :purpose => contract_purpose, :contract => contract, :model => item.model)
      end
    end

    def create_signed_contracts
      contract = FactoryGirl.create(:contract, :user => @delegation1, :delegated_user => @julie, :inventory_pool => @inventory_pool, :status => :approved)
      contract_purpose = FactoryGirl.create :purpose, :description => Faker::Lorem.sentence

      rand(3..5).times do
        item = FactoryGirl.create :item, inventory_pool: @inventory_pool
        contract.contract_lines << FactoryGirl.create(:contract_line, :purpose => contract_purpose, :contract => contract, :model => item.model)
      end

      contract.sign Persona.get(:pius)
    end

  end
end
