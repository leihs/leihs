module Availability
  module Model
    
    def availability_in(inventory_pool)
      # we keep the result in an instance variable to avoid recompute during the same request
      # NOTE this simple-cache doesn't seem to be influent, let's go normal
      #@av ||= {}
      #@av[inventory_pool.id] ||= 
      Availability::Main.new(:model => self, :inventory_pool => inventory_pool)
    end

    def total_borrowable_items_for_user(user, inventory_pool = nil)
      groups = user.groups.with_general
      if inventory_pool
        inventory_pool.partitions_with_generals.hash_for_model_and_groups(self, groups).values.sum
      else       
        inventory_pools.sum {|ip| ip.partitions_with_generals.hash_for_model_and_groups(self, groups).values.sum }
      end
    end

    def availability_periods_for_user(user, with_total_borrowable = false) #, start_date = Date.today, end_date = Availability::Change::ETERNITY)
      (inventory_pools & user.inventory_pools).collect do |inventory_pool|
        groups = user.groups.scoped_by_inventory_pool_id(inventory_pool).with_general
        h = {:inventory_pool => inventory_pool.as_json, # FIXME extract this ?? this is used for the frontend only ??
             :availability => availability_in(inventory_pool).available_quantities_for_groups(groups.map{|x| x.try(:id)}) }
        if with_total_borrowable
          h[:total_borrowable] = inventory_pool.hash_for_model_and_groups(self, groups).values.sum 
        end
        h
      end
    end
  end
end
