class Backend::AvailabilityController < Backend::BackendController
  
  def show
    @overbooking_changes = current_inventory_pool.overbooking_changes
  end

end
