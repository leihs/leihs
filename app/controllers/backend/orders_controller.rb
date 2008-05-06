class Backend::OrdersController < Backend::BackendController
  
    def index
      @orders = Order.find(:all)
    end
  
  
end
