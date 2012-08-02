module Json
  module ContractLineHelper

    def hash_for_contract_line(line, with = nil)
=begin
      h = line.as_json
      h[:model] = line.model.as_json(:methods => :package_models) # FIXME move package_models down to item_line ??
      
      if with ||= nil
        if with[:contract]
          h[:contract] = line.contract.as_json(:include => {:user => {:only => [:firstname, :lastname]}})
          h[:type] = (line.contract.status_const == 1) ? "hand_over_line" : "take_back_line"
        end
      end
=end

      h = {
            type: line.type.underscore,
            id: line.id,
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
          if [:hand_over, :take_back].include?(line.contract.action) 
            h[:availability_for_inventory_pool] = {}
          end
        end

      end
      
      h
    end

    def hash_for_item_line(line, with = nil)
      h = hash_for_contract_line line, with
      
      if with ||= nil
        if with[:item]
          h[:item] = line.item ? hash_for(line.item, with[:item]) : nil
        end

        if with[:availability]
          if [:hand_over, :take_back].include?(line.contract.action)
            borrowable_items = line.model.items.scoped_by_inventory_pool_id(current_inventory_pool).borrowable
            h[:total_rentable] = borrowable_items.count
            h[:total_rentable_in_stock] = borrowable_items.in_stock.count
            h[:total_borrowable] = line.model.total_borrowable_items_for_user(line.document.user, current_inventory_pool)
            av = line.model.availability_in(current_inventory_pool)
            h[:availability_for_inventory_pool] = {
              :partitions => (line.model.partitions.in(current_inventory_pool).by_groups(current_inventory_pool.groups) + line.model.partitions.in(current_inventory_pool).by_groups(Group::GENERAL_GROUP_ID)).as_json(:include => :group),
              :availability => av.available_total_quantities,
              :max_available => line.quantity + av.maximum_available_in_period_for_user(line.document.user, line.start_date, line.end_date)
            }
          end
=begin
          if (customer_user = with[:availability][:user])
            h[:total_borrowable] = line.model.total_borrowable_items_for_user(customer_user)
            h[:availability_for_user] = line.model.availability_periods_for_user(customer_user)
          end
=end
        end
        
        if with[:errors]
          h[:errors] = line.errors.full_messages
        end
      end
      
      h
    end

    def hash_for_option_line(line, with = nil)
      h = hash_for_contract_line line, with

      if with ||= nil
        if with[:item]
          #tmp# h[:item] = line.item ? hash_for(line.item, with[:item]) : nil
          h[:item] = {
            inventory_code: line.option.inventory_code,
            price: line.option.price
          }
        end
      end

      h
    end

  end
end
