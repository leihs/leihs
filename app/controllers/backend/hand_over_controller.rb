class Backend::HandOverController < Backend::BackendController
  
  def index
      @orders = Order.find(:all,
                       :conditions => {:status_const => Order::APPROVED},
                       :group => :user_id ) # TODO refactor in model

  end
  
  
end
