class Backend::OrdersController < Backend::BackendController
  
  before_filter :preload
  
  def index

    @orders = current_inventory_pool.orders

    if params[:query]
      # search with partial string
      @orders = @orders.find_by_contents("*" + params[:query] + "*")
    elsif @user
      @orders = @orders & @user.orders
    end
    
    render :partial => 'orders' if request.post?
    
  end
  
  private
  
  def preload
    @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
  end
  
end
