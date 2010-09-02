class Backend::AvailabilityController < Backend::BackendController
  
  def show
    @overbooking = AvailabilityChange.overbooking(current_inventory_pool)
  end

end
