class Backend::InventoryPoolsController < Backend::BackendController
  
  def index
    @inventory_pools = current_user.inventory_pools.select {|ip| current_user.has_role?('manager', ip) }.compact
    redirect_to backend_inventory_pool_path(@inventory_pools.first) if @inventory_pools.size == 1
  end

  def timeline
    @timeline_xml = current_inventory_pool.timeline
    render :nothing => true, :layout => $modal_timeline_layout_path
  end

  def timeline_visits
    @timeline_xml = current_inventory_pool.timeline_visits
    render :nothing => true, :layout => $modal_timeline_layout_path
  end


end
