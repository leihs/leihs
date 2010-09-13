class Backend::AvailabilityController < Backend::BackendController
  
  def show
    @overbooking_changes = Availability::Change.overbooking(current_inventory_pool, nil)
  end

end
