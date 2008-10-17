class Backend::OrdersController < Backend::BackendController
  
  before_filter :preload
  
  def index
    # TODO display approved orders?? remove approved orders when contract is generated?
    orders = current_inventory_pool.orders

    if !params[:query].blank?
      @orders = orders.find_by_contents("*" + params[:query] + "*", :page => params[:page], :per_page => Order.per_page)
    else
      orders = orders & @user.orders if @user
      @orders = orders.paginate :page => params[:page], :per_page => Order.per_page
    end
  
  # TODO *15* fix total_results, status 2 - 3
  end
  
  private
  
  def preload
    @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
  end
  
end
