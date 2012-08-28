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
          h.deep_merge! hash_for_availability(line)
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
