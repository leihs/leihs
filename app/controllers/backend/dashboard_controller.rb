class Backend::DashboardController < Backend::BackendController
  
  def index
  end

  #  TODO refactor in a dedicated controller?
  def index_inventory_pools    
      @inventory_pools = InventoryPool.find(:all)   
  end

  def index_items    
      @items = Item.find(:all)   
  end


end
