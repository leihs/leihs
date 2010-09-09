module Availability2
  module DocumentLine
    
    def available?
      # TODO check if I'm already allocated to a Group (non-General)
      # model.availability_changes.scoped_by_inventory_pool_id(inventory_pool).first(:conditions => {:date => start_date})
      
      Availability2::Change.overbooking(inventory_pool, model).between(start_date, end_date).empty?
    end

    def unavailable_periods
      # TODO check if I'm already allocated to a Group (non-General)
      
      changes = Availability2::Change.overbooking(inventory_pool, model)
      changes.collect do |c|
        { :start_date => c.start_date,
          :end_date => c.end_date }
      end
    end

  end
end