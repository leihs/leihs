module Availability
  module InventoryPool

    #1901#
    def overbooking_changes
      # TODO get multiple keys ??
      #changes = Rails.cache.fetch("/model/#{.*}/inventory_pool/#{id}/changes")
      #changes.overbooking
    end
   
    # OPTIMIZE used for extjs
    def items_size(model, user)
      model.partitions.in(self).by_groups(user.groups).sum(:quantity).to_i +
        model.partitions.in(self).by_group(Group::GENERAL_GROUP_ID)
    end
  end
end