module Json
  module OrderLineHelper

    def hash_for_order_line(line, with = nil)
      h = {
        type: "order_line",
        id: line.id
      }
      
      if with ||= nil
        [:model, :is_available, :inventory_pool_id, :quantity].each do |k|
          h[k] = line.send(k) if with[k]
        end
      
        if with[:order]
          h[:order] = hash_for line.order, with[:order] 
        end
        
        if with[:availability_for_inventory_pool]
          borrowable_items = line.model.items.scoped_by_inventory_pool_id(current_inventory_pool).borrowable
          h[:total_rentable] = borrowable_items.count
          h[:total_rentable_in_stock] = borrowable_items.in_stock.count
          h[:total_borrowable] = line.model.total_borrowable_items_for_user(line.user, current_inventory_pool)
          av = line.model.availability_in(current_inventory_pool)
          h[:availability_for_inventory_pool] = {
            :partitions => current_inventory_pool.partitions_with_generals.array_for_model_and_groups(line.model, current_inventory_pool.groups.with_general).as_json(:include => :group),
            :availability => av.available_total_quantities,
            :max_available => line.quantity + av.maximum_available_in_period_for_groups(line.groups, line.start_date, line.end_date)
          }
        end

=begin
        if with[:availability]
          if (customer_user = with[:availability][:user])
            h[:total_borrowable] = line.model.total_borrowable_items_for_user(customer_user)
            h[:availability_for_user] = line.model.availability_periods_for_user(customer_user, true)
          end
        end
=end
        
        if with[:dates]
          h[:start_date] = line.start_date
          h[:end_date] = line.end_date
        end
      end
      
      h
    end

  end
end
