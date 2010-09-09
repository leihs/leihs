module Availability2
  module DocumentLine
    
    def available?
      Availability2::Change.overbooking(inventory_pool, model).between(start_date, end_date).empty?
    end

  end
end