class Backend::DashboardController < Backend::BackendController
  require_role "inventory_manager", :for_all_except => [:index, :login, :switch_inventory_pool] # TODO for rspec tests
  
  def index
    # TODO temp
     if logged_in?
      self.current_inventory_pool = current_user.access_rights.detect {|a| a.role.name == 'inventory_manager'}.inventory_pool
    else
      session[:return_to] = request.request_uri
      redirect_to :controller => '/session', :action => 'new'
    end
    
  end

  # TODO temp forcing login
  def login
    if params[:id]
      self.current_user = User.find params[:id]
    else
      self.current_user ||= User.find :first
    end

  end

  #TODO temp forcing inventory_pool
  def switch_inventory_pool
    if params[:id]
      #session[:inventory_pool_id] = params[:id].to_i
      self.current_inventory_pool = InventoryPool.find(session[:id])
    #else
    #  session[:inventory_pool_id] ||= InventoryPool.find(:first).id
    end

    redirect_to :action => 'index'
  end

################################################

  #  TODO refactor in a dedicated controller?
  def index_inventory_pools    
      @inventory_pools = InventoryPool.find(:all)   
#      @inventory_pools = current_user.inventory_pools
  end

  def index_items    
#      @items = Item.find(:all)   
#      @items = current_user.inventory_pools.collect(&:items).flatten
       @items = current_inventory_pool.items
  end


end
