module Json
  module ModelHelper

    def hash_for_model(model, with = nil)
      h = {
        type: model.class.to_s.underscore,
        id: model.id,
        name: model.name,
        manufacturer: model.manufacturer
      }

      if with and with[:is_package]
        h[:is_package] = model.is_package?
      end
      
      if with ||= nil
        [:image_thumb, :description, :technical_detail, :internal_description, :is_package, :hand_over_note].each do |k|
          h[k] = model.send(k) if with[k]
        end
        
        if with[:properties]
          h[:properties] = model.properties.as_json # TODO
        end

        if with[:items] and model.respond_to? :items
          Item.unscoped do
            items = model.items 
            items = items.where("items.id IN (#{with[:items][:scoped_ids].to_sql})") unless with[:items][:scoped_ids].nil?
            items = items.search(with[:items][:query]) if with[:items][:query]
            h[:items] = hash_for items, with[:items]
          end
        end

        if with[:packages]
          Item.unscoped do
            packages = model.items.joins("JOIN items as i ON i.parent_id = items.id").uniq
            h[:packages] = hash_for packages, with[:packages]
          end
        end
      
        if with[:categories] and model.respond_to? :categories
          h[:categories] = model.categories.as_json # TODO
        end

        if with[:compatibles]
          h[:compatibles] = hash_for model.compatibles
        end

        if with[:images] and model.respond_to? :images
          h[:images] = model.images.as_json(:methods => [:public_filename, :public_filename_thumb]) # TODO
        end

        if with[:attachments] and model.respond_to? :attachments
          h[:attachments] = model.attachments.as_json(:methods => :public_filename) # TODO
        end

        if with[:accessories] and model.respond_to? :accessories
          h[:accessories] = model.accessories.map do |accessory|
            {id: accessory.id,
             name: accessory.name,
             active: accessory.inventory_pool_ids.include?(current_inventory_pool.id),
             is_deletable: (accessory.inventory_pool_ids.empty? or accessory.inventory_pool_ids == [current_inventory_pool.id])
            }
          end
        end

        if with[:inventory_pools]
          h[:inventory_pools] = hash_for model.inventory_pools, with[:inventory_pools]
        end
      
        if with[:availability]
          customer_user = with[:availability][:user] || User.find_by_id(with[:availability][:user_id])
          current_inventory_pool = with[:availability][:inventory_pool] || InventoryPool.find_by_id(with[:availability][:inventory_pool_id])
          start_date = Date.parse with[:availability][:start_date] if with[:availability] and with[:availability][:start_date]
          end_date = Date.parse with[:availability][:end_date] if with[:availability] and with[:availability][:end_date]
      
          if customer_user and current_inventory_pool and start_date and end_date
            av = model.availability_in(current_inventory_pool)
            h[:max_available] = av.maximum_available_in_period_for_groups(start_date, end_date, customer_user.group_ids)
            h[:max_available_in_total] = av.maximum_available_in_period_summed_for_groups(start_date, end_date)
            h[:total_rentable] = model.total_borrowable_items_for_user(customer_user, current_inventory_pool)
          elsif current_inventory_pool
            borrowable_items = model.items.scoped_by_inventory_pool_id(current_inventory_pool).borrowable
            h[:total_rentable_in_stock] = borrowable_items.in_stock.count
            h[:total_rentable] = borrowable_items.count
          elsif customer_user and current_inventory_pool.nil?
            # NOTE for frontend
            h[:total_borrowable] = model.total_borrowable_items_for_user(customer_user)
            h[:availability_for_user] = model.availability_periods_for_user(customer_user)
          end
        end

        if with[:max_partition_capacity]
          h[:max_partition_capacity] = model.items.scoped_by_inventory_pool_id(with[:max_partition_capacity]).borrowable.count
        end

        if with[:partitions]
          h[:partitions] = hash_for model.partitions, with[:partitions]
        end

        #tmp# TODO remove this when using permissions
        if with[:is_editable]
          h[:is_editable] = is_privileged_user?
        end

        if with[:is_destroyable]
          h[:is_destroyable] = model.can_destroy?
        end
      end
      
      h
    end

  end
end
