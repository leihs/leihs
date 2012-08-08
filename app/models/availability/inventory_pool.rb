module Availability
  module InventoryPool

    attr_accessor :loaded_group_ids

    def overbooking_availabilities
      models.collect do |model|
        a = model.availability_in(self)
        a if a.changes.any? {|k, c| c.quantities.any? {|g, q| q.in_quantity < 0 } }
      end.compact
    end

    # TODO
    #def availability_for(model)
    #  Availability::Main.new(:model => model, :inventory_pool => self)
    #end
   
  end
end
