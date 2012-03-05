# coding: UTF-8

# Persona:  Pius
# Job:      Inventory Pool Manager
#
require 'factory'

module Persona
  
  class Pius
    
    NAME = "Pius"
    LASTNAME = "C."
    PASSWORD = "password"
    EMAIL = "pius@zhdk.ch"
    INVENTORY_POOL_NAME = "A-Ausleihe"
    
    def initialize
      ActiveRecord::Base.transaction do 
      end
    end

  end  
end