class Backend::OrdersController < Backend::BackendController
  
  before_filter :preload
  
  def index
    orders = current_inventory_pool.orders
    orders = orders & @user.orders if @user # TODO 1209** @user.orders.by_inventory_pool(current_inventory_pool)

    case params[:filter]
      when "submitted"
        orders = orders.submitted
      when "approved"
        orders = orders.approved
      when "rejected"
        orders = orders.rejected
    end

    @orders = orders.search(params[:query], { :star => true,
                                              :page => params[:page],
                                              :per_page => $per_page } )
  end

  def show
      
  end
  
  
  private
  
  def preload
    params[:order_id] ||= params[:id] if params[:id]
    @order = current_inventory_pool.orders.find(params[:order_id]) if params[:order_id]
    @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
  end
  
end
