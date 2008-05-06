class Backend::OrdersController < Backend::BackendController
  
    def index
      @orders = Order.find(:all)
    end


    def to_deliver
      @orders = Order.find(:all,
                           :conditions => {:status_const => Order::APPROVED},
                           :group => :user_id ) # TODO refactor in model

      render :action => 'index'
    end
  
    def order_lines_to_deliver
      @orders = Order.find(:all,
                           :conditions => {:status_const => Order::APPROVED,
                                           :user_id => params[:user_id]})
  
      @order_lines = []
      @orders.each do |o|
#        @order_lines << o.order_lines
        o.order_lines.each { |ol| @order_lines << ol }
      end
      #TODO sort by start_date
  
      render :xml => @order_lines
    end

  
end
