# coding: UTF-8

# Persona:  Ramon
# Job:      Leihs Developer and Administrator
#
require 'factory'

module Persona
  
  class Ramon
    
    NAME = "Ramon"
    LASTNAME = "C."
    PASSWORD = "password"
    EMAIL = "ramon@zhdk.ch"
    
    def initialize
      ActiveRecord::Base.transaction do 
        create_minimal_setup
        create_admin_user
        create_inventory_pool
      end
    end
    
    def create_admin_user
      @user = Factory(:user, :firstname => NAME, :lastname => LASTNAME, :login => NAME.downcase, :email => EMAIL)
      @user.access_rights.create(:role => Role.find_or_create_by_name("admin"))
      @database_authentication = Factory(:database_authentication, :user => @user, :password => PASSWORD)
    end
    
    def create_minimal_setup
      Factory.create_default_languages
      Factory.create_default_authentication_systems
      Factory.create_default_roles
      Factory.create_default_building
    end
    
    def create_inventory_pool
      description = "Wichtige Hinweise.."
      contact_details = "AV Verleih  /  ZHdK\nausleihe.pz@zhdk.ch\n+41 43 446 44 45"
      Factory(:inventory_pool, :name => "AV-Ausleihe", :description => description, :contact_details => contact_details, :contract_description => "Audio Visueller Verleih", :email => "ausleihe@zhdk.ch", :shortname => "AVA")
    end

  end  
end
