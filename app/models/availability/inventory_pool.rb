module Availability
  module InventoryPool

    attr_accessor :loaded_group_ids

#old leihs#
=begin
    def overbooking_availabilities
      models.collect do |model|
        a = model.availability_in(self)
        a if a.changes.any? {|k, c| c.any? {|g, q| q[:in_quantity] < 0 } }
      end.compact
    end
=end

    # TODO
    #def availability_for(model)
    #  Availability::Main.new(:model => model, :inventory_pool => self)
    #end
   
  end
end
