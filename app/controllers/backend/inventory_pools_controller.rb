class Backend::InventoryPoolsController < Backend::BackendController
  
  def index
    inventory_pools = InventoryPool

    unless params[:query].blank?
      @inventory_pools = inventory_pools.search(params[:query], :page => params[:page], :per_page => $per_page)
    else
      @inventory_pools = inventory_pools.paginate :page => params[:page], :per_page => $per_page
    end
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
