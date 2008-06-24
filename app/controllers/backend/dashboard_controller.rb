class Backend::DashboardController < Backend::BackendController
  require_role "inventory_manager", :for_all_except => [:index, :login, :switch_inventory_pool] # TODO for rspec tests
  
  def index
  end

  # TODO temp forcing login
#  def login
#    if params[:id]
#      self.current_user = User.find params[:id]
#    else
#      self.current_user ||= User.find :first
#    end
#
#  end

  #TODO temp forcing inventory_pool
  def switch_inventory_pool
    if params[:id]
      self.current_inventory_pool = InventoryPool.find(params[:id])
    #else
    #  session[:inventory_pool_id] ||= InventoryPool.find(:first).id
    end

    redirect_to :action => 'index'
  end

################################################

  #  TODO refactor in a dedicated controller?
  def index_inventory_pools    
      @inventory_pools = InventoryPool.find(:all)   
  end

  #  TODO refactor in a dedicated controller?
  def index_items    
#old#      @items = Item.find(:all)
       @items = current_inventory_pool.items
  end


end
