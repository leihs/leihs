module Json
  module AvailabilityHelper

    def hash_for_availability(line, with = nil)
      # this is a cache preventing multiple computation for the same user and model and (current) inventory_pool during a single request
      @hash_for_availability ||= {:models => {}}
      @hash_for_availability[line.model_id] ||= {:av => line.model.availability_in(current_inventory_pool),
                                                 :users => {}}

      @hash_for_availability[line.model_id][:users][line.user.id] ||= begin
        borrowable_items = line.model.items.scoped_by_inventory_pool_id(current_inventory_pool).borrowable
        {
          :total_rentable => borrowable_items.count,
          :total_rentable_in_stock => borrowable_items.in_stock.count,
          :total_borrowable => line.model.total_borrowable_items_for_user(line.user, current_inventory_pool),
          :availability_for_inventory_pool => {
            :partitions => current_inventory_pool.partitions_with_generals.array_for_model_and_groups(line.model, current_inventory_pool.groups.with_general).as_json(:include => :group),
            :changes => @hash_for_availability[line.model_id][:av].available_total_quantities
          }
        }
      end
      
      @hash_for_availability[line.model_id][:users][line.user.id].deep_merge({
        :availability_for_inventory_pool => {
          :max_available => line.quantity + @hash_for_availability[line.model_id][:av].maximum_available_in_period_for_groups(line.start_date, line.end_date, line.group_ids)
        }
      })
    end

  end
end