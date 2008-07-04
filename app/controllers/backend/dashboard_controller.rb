class Backend::DashboardController < Backend::BackendController
  require_role "inventory_manager", :for_all_except => [:index, :login, :index_inventory_pools, :switch_inventory_pool] # TODO for rspec tests
  
  def index
  end


  def switch_inventory_pool
    self.current_inventory_pool = InventoryPool.find(params[:id]) if params[:id]

    redirect_to :action => 'index'
  end

################################################

  #  TODO refactor in a dedicated controller?
  def index_inventory_pools    
      @inventory_pools = InventoryPool.find(:all)   

    render :layout => false if request.post?
  end

  #  TODO refactor in a dedicated controller?
  def index_items
    
    @items = current_inventory_pool.items

    if params[:search]
      @items = @items.find_by_contents(params[:search])
    end

    render :layout => false if request.post?
  end


end
