# coding: UTF-8

# Persona:  Mike
# Job:      Inventory Pool Manager
#

module Persona
  
  class Mike
    
    NAME = "Mike"
    LASTNAME = "Hon"
    PASSWORD = "password"
    
    def initialize
      ActiveRecord::Base.transaction do 
        create_user
      end
    end
    
    def create_user
    end

  end  
end
