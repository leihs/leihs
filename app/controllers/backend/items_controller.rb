class Backend::ItemsController < Backend::BackendController
  active_scaffold :item do |config|
    config.columns = [:model, :inventory_pool, :location, :inventory_code, :serial_number, :status_const, :in_stock?]
    config.columns.each { |c| c.collapsed = true }

    config.list.sorting = { :model => :asc }
    config.action_links.add 'toggle_status', :label => 'Toggle borrowable status', :type => :record # TODO optimize
  end

  # filter for active_scaffold through location
  def conditions_for_collection
    # TODO return nil if current_user role is 'Admin'
    #old# {:inventory_pool_id => current_inventory_pool.id}
    ['locations.inventory_pool_id = ?', current_inventory_pool.id] 
  end

  def details
    @item = current_inventory_pool.items.find(params[:id])
 
    render :layout => $modal_layout_path
  end
  
#################################################################

  # TODO remove, refactor for active_scaffold
  def index_old
    @items = current_inventory_pool.items

    if params[:search]
      @items = @items.find_by_contents(params[:search])
    end

    render :layout => false if request.post?  
  end

  def toggle_status
    @item = current_inventory_pool.items.find(params[:id])
    @item.status_const = (@item.status_const == Item::BORROWABLE ? Item::UNBORROWABLE : Item::BORROWABLE)
    @item.save
    render :text => "Status changed"
  end

end
