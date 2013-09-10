module Json
  module ContractLineHelper

    def hash_for_contract_line(line, with = nil)

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

        if with[:returned_to_user]
          h[:returned_to_user] = line.returned_to_user.try(:short_name)
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
            h.deep_merge! hash_for_availability(line)
          end
=begin
          if (customer_user = with[:availability][:user])
            h[:total_borrowable] = line.model.total_borrowable_items_for_user(customer_user)
            h[:availability_for_user] = line.model.availability_periods_for_user(customer_user)
          end
=end
        end
        
        if with[:errors]
          h[:errors] = line.errors.full_messages.uniq
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
