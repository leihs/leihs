# -*- encoding : utf-8 -*-
module Availability
  module Model
    
    def availability_cache_key(inventory_pool)
      "/model/#{id}/inventory_pool/#{inventory_pool.id}/changes"
    end

    def availability_changes_in(inventory_pool)
      Rails.cache.fetch(availability_cache_key(inventory_pool)) do
        Availability::Main.new(:model_id => id, :inventory_pool_id => inventory_pool.id)
      end
    end

    def delete_availability_changes_in(inventory_pool)
      #1402
      partitions.in(inventory_pool).by_group(Group::GENERAL_GROUP_ID)

      Rails.cache.delete(availability_cache_key(inventory_pool))
    end

    #def total_available_in_period_for_user(user, start_date = Date.today, end_date = Date.today)
    #  inventory_pools.collect do |ip|
    #    availability_changes_in(ip).maximum_available_in_period_for_user(user, start_date, end_date)
    #  end.sum
    #end

    def total_borrowable_items_for_user(user)
      inventory_pools.collect do |ip|
        partitions.in(ip).by_groups(user.groups).sum(:quantity).to_i +
          partitions.in(ip).by_group(Group::GENERAL_GROUP_ID, false)
      end.sum
    end

    def availability_periods_for_user(user, with_total_borrowable = false, start_date = Date.today, end_date = Availability::ETERNITY)
      (inventory_pools & user.inventory_pools).collect do |inventory_pool|
        groups = user.groups.scoped_by_inventory_pool_id(inventory_pool)
        h = {:inventory_pool => {:id => inventory_pool.id,
                             :name => inventory_pool.to_s,
                             :address => inventory_pool.address.to_s,
                             :closed_days => inventory_pool.workday.closed_days },
             :availability => availability_changes_in(inventory_pool).changes.available_quantities_for_groups(groups, true) }
        if with_total_borrowable
          h[:total_borrowable] = partitions.in(inventory_pool).by_groups(groups.collect(&:id)).sum(:quantity).to_i +
                                 partitions.in(inventory_pool).by_group(Group::GENERAL_GROUP_ID)
        end
        h
      end
    end


    ########################################################################

    def as_json(options = {})
      json = super(options)
      if options[:current_user]
        json['total_borrowable'] = total_borrowable_items_for_user(options[:current_user])
        json['availability'] = availability_periods_for_user(options[:current_user])
      end
      json
    end


  end
end
