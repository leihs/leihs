# coding: UTF-8

# Persona:  Mina
# Job:      Delegated customer
#

module Persona

  class Mina

    @@name = "Mina"
    @@lastname = Faker::Name.last_name
    @@email = "mina@zhdk.ch"
    @@inventory_pool_name = "A-Ausleihe"

    def initialize
      setup_dependencies

      ActiveRecord::Base.transaction do
        select_inventory_pool
        create_user
      end
    end

    def setup_dependencies 
      Persona.create :mike
    end

    def select_inventory_pool
      @inventory_pool = InventoryPool.find_by_name(@@inventory_pool_name)
    end

    def create_user
      @user = FactoryGirl.create(:user, firstname: @@name, lastname: @@lastname, login: @@name.downcase, email: @@email)
      @user.access_rights.create(:role => :customer, :inventory_pool => @inventory_pool)
    end

  end
end
