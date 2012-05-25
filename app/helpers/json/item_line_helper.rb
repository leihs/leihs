module Json
  module ItemLineHelper

    def hash_for_item_line(line, with = nil)
      h = {
            id: line.id,
            type: line.type.underscore,
            start_date: line.start_date,
            end_date: line.end_date,
            quantity: line.quantity           
          }
      
      if with ||= nil
        [:returned_date].each do |k|
          h[k] = line.send(k) if with[k]
        end
      
        if with[:is_valid]
          h[:is_valid] = line.valid?
        end
      
        if with[:item]
          h[:item] = line.item ? hash_for(line.item, with[:item]) : nil
        end
        
        if with[:model]
          h[:model] = hash_for(line.model, with[:model])
        end
      
        if with[:contract]
          h[:contract] = hash_for(line.contract, with[:contract])
        end
      
        if with[:purpose]
          h[:purpose] = line.purpose ? hash_for(line.purpose, with[:purpose]) : nil
        end
      
        if with[:availability]
          if line.contract.action == :hand_over
            borrowable_items = line.model.items.scoped_by_inventory_pool_id(current_inventory_pool).borrowable
            h[:total_rentable] = borrowable_items.count
            h[:total_rentable_in_stock] = borrowable_items.in_stock.count
            h[:availability_for_inventory_pool] = {
              :partitions => (line.model.partitions.in(current_inventory_pool).by_groups(current_inventory_pool.groups) + line.model.partitions.in(current_inventory_pool).by_groups(Group::GENERAL_GROUP_ID)).as_json(:include => :group),
              :availability => line.model.availability_changes_in(current_inventory_pool).changes.available_total_quantities
            }
          end
        end
        
        if with[:errors]
          h[:errors] = line.errors.full_messages
        end
      end
      
      h
    end

  end
end
