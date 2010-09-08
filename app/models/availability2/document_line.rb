module Availability2
  module DocumentLine
    
    # TODO cache ??
    def available?
      Availability2::Change.overbooking_for_model(model, inventory_pool).detect {|o| o[:start_date] <= end_date and o[:end_date] >= start_date }.nil?
    end

  end

end