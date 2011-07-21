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

    def total_available_in_period_for_user(user, start_date = Date.today, end_date = Date.today)
      inventory_pools.collect do |ip|
        availability_changes_in(ip).maximum_available_in_period_for_user(user, start_date, end_date)
      end.sum
    end

    def total_borrowable_items_for_user(user)
      inventory_pools.collect do |ip|
        partitions.in(ip).by_groups(user.groups).sum(:quantity).to_i +
          partitions.in(ip).by_group(Group::GENERAL_GROUP_ID)
      end.sum
    end

  end
end
