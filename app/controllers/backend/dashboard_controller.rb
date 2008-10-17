class Backend::DashboardController < Backend::BackendController
  
  def index
  end


################################################

  #  TODO refactor in a dedicated controller?

  def index_inventory_pools
    
    unless params[:query].blank?
      inventory_pools = InventoryPool.all(:conditions => ["name LIKE ?", "%" + params[:query] + "%"])
    else
      inventory_pools = InventoryPool.all      
    end

    @inventory_pools = inventory_pools.paginate :page => params[:page], :per_page => 3

  end

  def switch_inventory_pool
    self.current_inventory_pool = InventoryPool.find(params[:id]) if params[:id]

    redirect_to :action => 'index'
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
