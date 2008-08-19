class Backend::LocationsController < Backend::BackendController
  active_scaffold :location do |config|
    config.columns = [:building, :room, :shelf, :inventory_pool, :items]
    config.columns.each { |c| c.collapsed = true }

#    config.actions.exclude :create, :update, :delete
  end

  # filter for active_scaffold
  def conditions_for_collection
    # TODO return nil if current_user role is 'Admin'
    {:inventory_pool_id => current_inventory_pool.id}
  end

end
  
