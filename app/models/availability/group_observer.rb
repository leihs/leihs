module Availability
    class GroupObserver < ActiveRecord::Observer
      observe :group
      
      def after_destroy(group)
        ip = group.inventory_pool
        # TODO: get to models directly.
        one_availability_per_model = Availability::Change.scoped_by_inventory_pool_id(ip).find(
                      :all,
                      :select => "DISTINCT model_id",
                      :joins  => "INNER JOIN availability_quantities " \
                                 "ON availability_changes.id = availability_quantities.change_id " \
                                 "AND availability_quantities.group_id = #{group.id}")
  
        one_availability_per_model.each do |a|
          model = a.model
          Availability::Change.recompute( model, ip) 
        end      
      end
    end
end
