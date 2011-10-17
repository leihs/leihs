class Backend::AvailabilityController < Backend::BackendController
  
  def show
    @overbooking_availabilities = current_inventory_pool.overbooking_availabilities
  end

end
