class Backend::OrdersController < Backend::BackendController
  
    before_filter :preload
  
    def index
      @orders = (@user ? @user.orders : Order.find(:all) )
    end
  
    private
    
    def preload
      @user = User.find(params[:user_id]) if params[:user_id]
    end
  
end
