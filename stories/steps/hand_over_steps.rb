steps_for(:hand_over) do

  
  Given "the list of approved orders contains $total elements" do | total |
    orders = Order.approved_orders
    user = Factory.create_user(:login => name)
    total.to_i.times { orders << Factory.create_order(:user_id => user.id, :status_const => Order::APPROVED) }
    orders.size.should == total.to_i
  end

  When "a new order with $size order lines is placed by a user named '$who'" do | size, who |
    user = Factory.create_user(:login => who)
    @order = Factory.create_order({:user_id => user.id}, {:order_lines => size.to_i})
    @order.order_lines.size.should == size.to_i
  end
  
  
  When "an inventory_manager approves the order" do
    post "/backend/acknowledge/approve", :id => @order.id, :comment => "test comment"
    @order = assigns(:order)
    @order.should_not be_nil
  end


  When "$who clicks '$action'" do | who, action |
    get "/backend/#{action}/index"
    @orders = assigns(:orders) # TODO get group by
    response.should render_template("backend/#{action}/index")
  end
  
    
  Then "he sees $total element$s_1 with $size line$s_2" do | total, s_1, size, s_2 |
    @orders.size.should == total.to_i
    @order_lines = []
    @orders.each do |o|
       o.order_lines.each { |ol| @order_lines << ol }
    end
    @order_lines.size.should == size.to_i
  end
  

###############################################

  
end
