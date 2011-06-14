module Availability
  module InventoryPool

    def overbooking_availabilities
      # TODO get multiple cached key: Rails.cache.fetch("/model/#{.*}/inventory_pool/#{id}/changes")

      models.collect do |model|
        a = model.availability_changes_in(self)
        a if a.changes.any? {|c| c.quantities.any? {|q| q.in_quantity < 0 } }
      end.compact
    end
   
    # OPTIMIZE used for extjs
    # the arguments model and user are passed as class variables
    # TODO: improve
    # the problem is, that we need to call this from models_controller to
    # serialize data - where we can not pass any arguments
    def items_size
      model, user = [self.class.current_model, self.class.current_user]
      model.partitions.in(self).by_groups(user.groups).sum(:quantity).to_i +
        model.partitions.in(self).by_group(Group::GENERAL_GROUP_ID)
    end
  end
end
