class Backend::AvailabilityController < Backend::BackendController
  
  def show
    @overbooking_changes = current_inventory_pool.availability_changes.overbooking
  end

end
