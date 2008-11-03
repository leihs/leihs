class Backend::InventoryPoolsController < Backend::BackendController
  
  def index
    inventory_pools = InventoryPool
    
    unless params[:query].blank?
      inventory_pools = inventory_pools.all(:conditions => ["name LIKE ?", "%" + params[:query] + "%"])
    end

    @inventory_pools = inventory_pools.paginate :page => params[:page], :per_page => $per_page
  end

  def timeline
    @timeline_xml = current_inventory_pool.timeline
    render :nothing => true, :layout => 'backend/' + $theme + '/modal_timeline'
  end

  def timeline_visits
    @timeline_xml = current_inventory_pool.timeline_visits
    render :nothing => true, :layout => 'backend/' + $theme + '/modal_timeline'
  end


end
