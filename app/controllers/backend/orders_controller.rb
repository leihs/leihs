class Backend::OrdersController < Backend::BackendController
  
  before_filter :preload
  
  def index

    @orders = current_inventory_pool.orders

    if params[:search]
      params[:search] = "*#{params[:search]}*" # search with partial string
      @orders = @orders.find_by_contents(params[:search])
    elsif @user
      @orders = @orders & @user.orders
    end
    
    render :partial => 'orders' if request.post?
    
  end
  
  private
  
  def preload
    @user = User.find(params[:user_id]) if params[:user_id] # TODO scope current_inventory_pool
  end
  
end
