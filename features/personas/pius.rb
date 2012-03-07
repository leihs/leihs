# coding: UTF-8

# Persona:  Pius
# Job:      Inventory Pool Manager
#

module Persona
  
  class Pius
    
    @@name = "Pius"
    @@lastname = "C."
    @@password = "password"
    @@email = "pius@zhdk.ch"
    @@inventory_pool_name = "A-Ausleihe"
    
    def initialize
      ActiveRecord::Base.transaction do 
      end
    end

  end  
end