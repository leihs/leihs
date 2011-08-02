class InventoryPoolsController < FrontendController

  def index
    @inventory_pools = current_user.inventory_pools
  end  

#######################################################  
  
  def show
    @inventory_pool = current_user.inventory_pools.find(params[:id])
  end

#################################################################


end
