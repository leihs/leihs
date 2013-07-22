class Borrow::AvailabilityController < Borrow::ApplicationController

    def show
      model = current_user.models.borrowable.find params[:model_id]
      inventory_pool = current_user.inventory_pools.find params[:inventory_pool_id]
      av = model.availability_in(inventory_pool)
      @availability = 
        {
          changes: model.availability_in(inventory_pool).available_total_quantities,
          total_borrowable: model.total_borrowable_items_for_user(current_user, inventory_pool),
          inventory_pool_id: inventory_pool.id,
          model_id: model.id
        }
    end

end
