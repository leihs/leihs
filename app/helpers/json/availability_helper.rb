module Json
  module AvailabilityHelper

    def hash_for_availability(line, with = nil)
      borrowable_items = line.model.items.scoped_by_inventory_pool_id(current_inventory_pool).borrowable
      av = line.model.availability_in(current_inventory_pool)
      {
        :total_rentable => borrowable_items.count,
        :total_rentable_in_stock => borrowable_items.in_stock.count,
        :total_borrowable => line.model.total_borrowable_items_for_user(line.user, current_inventory_pool),
        :availability_for_inventory_pool => {
          :document_lines => av.document_lines, # TODO REMOVE ? not needed?
          :partitions => current_inventory_pool.partitions_with_generals.array_for_model_and_groups(line.model, current_inventory_pool.groups.with_general).as_json(:include => :group),
          :changes => av.available_total_quantities,
          :max_available => line.quantity + av.maximum_available_in_period_for_groups(line.start_date, line.end_date, line.group_ids)
        }
      }
    end
  end
end