class Borrow::InventoryPoolsController < Borrow::ApplicationController
  
  def index
    @inventory_pools = current_user.inventory_pools.with_borrowable_items.sort_by {|ip| ip.name}
  end
end
