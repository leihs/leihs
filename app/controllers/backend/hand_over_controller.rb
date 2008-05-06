class Backend::HandOverController < Backend::BackendController
  
  def index
#      orders = Order.find(:all,
#                           :conditions => {:status_const => Order::APPROVED},
#                           :group => :user_id )
      orders = Order.approved_orders
                           
#      @users = orders.collect {|o| o.user }.uniq
#      @order_lines = orders.collect {|o| o.order_lines }.flatten

      @orders = orders #TODO temp


      
      
      

      @grouped_lines = OrderLine.find_by_sql("SELECT u.id AS user_id,
                                                   u.login AS user_login,
                                                   sum(ol.quantity) AS quantity,
                                                   ol.start_date
                                            FROM order_lines ol JOIN orders o ON ol.order_id = o.id
                                                                JOIN users u ON o.user_id = u.id
                                            WHERE o.status_const = 2
                                            GROUP BY ol.start_date, u.id 
                                            ORDER BY ol.start_date, u.id") 



  end
  
  
end
