module Json
  module ItemHelper

    def hash_for_item(item, with = nil)
      h = {
        id: item.id,
        inventory_code: item.inventory_code,
        type: item.class.to_s.underscore
      }
      
      if with ||= nil
        [:current_borrower,
         :current_return_date,
         :in_stock?,
         :inventory_pool,
         :invoice_date,
         :invoice_number,
         :is_borrowable,
         :is_broken,
         :is_incomplete,
         :is_inventory_relevant,
         :last_check,
         :name,
         :note,
         :price,
         :properties,
         :responsible,
         :retired_reason,
         :serial_number,
         :user_name].each do |k|
          h[k] = item.send(k) if with[k]
        end
        
        if with[:in_stock]
          h[:in_stock] = item.in_stock?
        end

        if with[:retired]
          h[:retired] = ! item.retired.nil?
        end

        if with[:location_as_string]
          h[:location] = if item.owner != item.inventory_pool 
            location = []
            location.push item.inventory_pool.to_s if item.inventory_pool
            location.push item.location.to_s if item.location
            location.join ", "
          else 
            item.location.to_s
          end
        end

        if with[:location]
          h[:location] = hash_for item.location if item.location
        end

        if with[:owner]
          h[:owner] = hash_for item.owner
        end

        if with[:supplier]
          h[:supplier] = hash_for item.supplier if item.supplier
        end
      
        if with[:model]
          h[:model] = hash_for item.model, with[:model]
        end
        
        if with[:children] and item.model.is_package? and not item.children.empty?
          h[:children] = hash_for item.children, with[:children]
        end
      end
      
      h
    end

  end
end
