# coding: UTF-8

# Persona:  Mike
# Job:      Inventory Manager, 
#
require 'factory'

module Persona
  
  class Mike
    
    NAME = "Mike"
    LASTNAME = "H."
    PASSWORD = "password"
    EMAIL = "mike@zhdk.ch"
    
    def initialize
      ActiveRecord::Base.transaction do 
      end
    end

  end  
end
