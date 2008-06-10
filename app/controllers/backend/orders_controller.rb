class Backend::OrdersController < Backend::BackendController
  
  before_filter :preload
  
  def index
    
    if params[:search]
      params[:search] = "*#{params[:search]}*" # search with partial string
      @orders = Order.find_by_contents(params[:search])
    elsif @user
      @orders = @user.orders
    else
#      @orders = Order.find(:all)
       @orders = current_inventory_pool.orders
    end
    
    render :partial => 'orders' if request.post?
    
  end
  
  private
  
  def preload
    @user = User.find(params[:user_id]) if params[:user_id]
  end
  
end
