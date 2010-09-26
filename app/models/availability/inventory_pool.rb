module Availability
  module InventoryPool

    def self.included(base)
      base.has_many :availability_changes, :class_name => "Availability::Change"
    end
   
    # OPTIMIZE used for extjs
    def items_size(model, user)
      change = model.availability_changes.in(self).last
      return 0 if changes.nil?
      
      
#      # TODO: will be simpler with a general group. Additionaly use Group::GENERAL_GROUP_ID instead of NULL
      conditions = ["group_id IS NULL"]
      unless user.groups.empty?
        conditions[0] += " OR group_id IN (?)"
        conditions << user.groups
      end

#      # change.quantities.select(:select => "SUM(in_quantity) + SUM(out_quantity)", :conditions => conditions).to_i
#      # SELECT ... IN (NULL) doesn't work...
#      
       change.quantities.sum(:in_quantity, :conditions => conditions).to_i \
       + change.quantities.sum(:out_quantity, :conditions => conditions).to_i
    end
  end
end