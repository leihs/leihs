# coding: UTF-8

# Persona:  Mina
# Job:      Delegated customer
#

module Persona

  class Mina

    @@name = "Mina"
    @@lastname = Faker::Name.last_name
    @@email = "mina@zhdk.ch"

    def initialize
      setup_dependencies

      ActiveRecord::Base.transaction do
        create_user
      end
    end

    def setup_dependencies 
      Persona.create :mike
    end

    def create_user
      @user = FactoryGirl.create(:user, firstname: @@name, lastname: @@lastname, login: @@name.downcase, email: @@email)
    end

  end
end
