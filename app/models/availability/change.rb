module Availability
  
  class Change
    
    ETERNITY = Date.parse("3000-01-01")
    REPLACEMENT_INTERVAL = 1.month #1.year
    
    attr_accessor :date
    attr_accessor :quantities

    def initialize(attr)
      @date = attr[:date]
      @quantities = {}
    end
  
    def start_date
      date
    end
  
    def in_quantity_in_group(group_id)
      quantities[group_id].try(:in_quantity).to_i
    end

  end

end

