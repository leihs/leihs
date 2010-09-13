module Availability
  module InventoryPool

    # OPTIMIZE used for extjs
    def items_size(model_id, user)
      a_change = Availability::Change.scoped_by_inventory_pool_id(self).scoped_by_model_id(model_id).last
      return 0 if changes.nil?
      
      
#      # TODO: will be simpler with a general group. Additionaly use Group::GENERAL_GROUP_ID instead of NULL
      conditions = ["group_id IS NULL"]
      unless user.groups.empty?
        conditions[0] += " OR group_id IN (?)"
        conditions << user.groups
      end

#      # a_change.quantities.select(:select => "SUM(in_quantity) + SUM(out_quantity)", :conditions => conditions).to_i
#      # SELECT ... IN (NULL) doesn't work...
#      
       a_change.quantities.sum(:in_quantity, :conditions => conditions).to_i \
       + a_change.quantities.sum(:out_quantity, :conditions => conditions).to_i
    end
  end
end