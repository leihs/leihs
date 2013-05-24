# coding: UTF-8

# Persona:  Gino
# Job:      Admin
#

module Persona
  class Gino
    @@name = "Gino"
    @@lastname = "F."
    @@password = "password"
    @@email = "gino@zhdk.ch"

    def initialize
      ActiveRecord::Base.transaction do
        create_minimal_setup
        create_admin_user
      end
    end

    def create_minimal_setup
      LeihsFactory.create_default_languages
      LeihsFactory.create_default_authentication_systems
      LeihsFactory.create_default_roles
      LeihsFactory.create_default_building
    end

    def create_admin_user
      @language = Language.find_by_locale_name "de-CH"
      @user = FactoryGirl.create(:user, :language => @language, :firstname => @@name, :lastname => @@lastname, :login => @@name.downcase, :email => @@email)
      @user.access_rights.create(:role => Role.find_by_name("admin"))
      @database_authentication = FactoryGirl.create(:database_authentication, :user => @user, :password => @@password)
    end
  end
end
