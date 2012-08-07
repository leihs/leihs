module Availability
  module InventoryPool

    attr_accessor :running_lines

    def overbooking_availabilities
      models.collect do |model|
        a = model.availability_in(self)
        a if a.changes.any? {|k, c| c.quantities.any? {|g, q| q.in_quantity < 0 } }
      end.compact
    end
   
  end
end
