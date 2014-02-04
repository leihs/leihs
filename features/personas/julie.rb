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
        create_delegation
      end
    end

    def setup_dependencies 
      Persona.create :mina
    end

    def select_inventory_pool
      @inventory_pool = InventoryPool.find_by_name(@@inventory_pool_name)
    end

    def create_user
      @user = FactoryGirl.create(:user, firstname: @@name, lastname: @@lastname, login: @@name.downcase, email: @@email)
      @user.access_rights.create(:role => :customer, :inventory_pool => @inventory_pool)
    end

    def create_delegation
      delegation = FactoryGirl.create(:user, delegator_user: @user,
                                             firstname: Faker::Lorem.sentence,
                                             lastname: Faker::Lorem.sentence,
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
      delegation.users << Persona.get(:mina)
      delegation.access_rights.create(:role => :customer, :inventory_pool => @inventory_pool)
    end

  end
end
