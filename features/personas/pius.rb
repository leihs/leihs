# coding: UTF-8

# Persona:  Pius
# Job:      Inventory
#
require 'factory'

module Persona
  
  class Ramon
    
    NAME = "Pius"
    LASTNAME = ""
    PASSWORD = "password"
    EMAIL = "ramon.cahn@zhdk.ch"
    
    def initialize
      ActiveRecord::Base.transaction do 
      end
    end

  end  
end