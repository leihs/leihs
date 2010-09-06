class Backend::AvailabilityController < Backend::BackendController
  
  def show
    @overbooking = Availability2::Change.overbooking(current_inventory_pool)
  end

end
