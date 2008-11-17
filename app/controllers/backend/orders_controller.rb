class Backend::OrdersController < Backend::BackendController
  
  before_filter :preload
  
  def index
    # TODO display approved orders?? remove approved orders when contract is generated?
    orders = current_inventory_pool.orders
    orders = orders & @user.orders if @user

    case params[:filter]
      when "submitted"
        orders = orders.submitted_orders
      when "approved"
        orders = orders.approved_orders
    end

    unless params[:query].blank?
      @orders = orders.find_by_contents(params[:query], :page => params[:page], :per_page => $per_page)
    else
      @orders = orders.paginate :page => params[:page], :per_page => $per_page
    end
  end
  
  private
  
  def preload
    @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
  end
  
end
