module Availability
  module InventoryPool

    def overbooking_availabilities
      # TODO get multiple cached key: Rails.cache.fetch("/model/#{.*}/inventory_pool/#{id}/changes")

      models.collect do |model|
        a if a.changes.any? {|c| c.quantities.any? {|q| q.in_quantity < 0 } }
        a = model.availability_in(self)
      end.compact
    end
   
  end
end
