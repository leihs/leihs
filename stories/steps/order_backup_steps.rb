steps_for(:order) do
 
  Given "the list of new orders contains $total elements" do | total |
    orders = Order.new_orders
    user = Factory.create_user(:login => name)
    total.to_i.times { orders << Factory.create_order(:user_id => user.id) }
    orders.size.should == total.to_i
  end

  When "$who clicks '$action'" do | who, action |
    get "/backend/#{action}/index"
    @orders = assigns(:new_orders)
    response.should render_template('backend/acknowledge/index')   
  end
  
  Then "$who sees $size_n new order$s_n and $size_d draft order$s_d" do | who, size_n, s_n, size_d, s_d |
    @orders.select{|o| !o.has_backup? }.size.should == size_n.to_i
    @orders.select{|o| o.has_backup? }.size.should == size_d.to_i
  end

  When "$who chooses one order" do | who |
    order = @orders.first
    get "/backend/acknowledge/show/#{order.id}"
    response.should render_template('backend/acknowledge/show')
    @order = assigns(:order)
  end

  Then "a backup for the order is generated" do
    @order.has_backup?.should == true
  end

###############################################


  Given "a new order with $size order lines" do | size |
    user = Factory.create_user(:login => "Joe")
    @order = Factory.create_order({:user_id => user.id}, {:order_lines => size.to_i})
    @original_order = @order
    @order.order_lines.size.should == size.to_i
  end

  Given "the order has $size changes" do | size |
    @order.histories.size.should == size.to_i
  end

  When "$who chooses the order" do | who |
    order = @order
    get "/backend/acknowledge/show/#{order.id}"
    response.should render_template('backend/acknowledge/show')
    @order = assigns(:order)
  end

  When "$who deletes $size order line$s" do | who, size, s |
    size.to_i.times { @order.remove_line(@order.order_lines.first.id, @order.user.id) }
  end

  Then "the order has $size order line$s" do | size, s |
    @order.order_lines.size.should == size.to_i  
  end

  Then "the order has $size changes" do | size |
    @order.histories.size.should == size.to_i
  end
  
  When "$who restores the order" do | who |
    @order.from_backup
  end

  Then "the restored order has the same $size order line$s as the original" do | size, s |
    @order.order_lines.size.should == size.to_i 
    @original_order.order_lines.size.should == size.to_i
    equal_collections?(@order.order_lines, @original_order.order_lines).should == true
  end

  Then "the restored order has the same $size change$s as the original" do | size, s |
    @order.histories.size.should == size.to_i 
    @order.histories.should == @original_order.histories
  end

  Then "is redirected to '$action'" do | action |
    get "/backend/#{action}/index"
    @orders = assigns(:new_orders)
    response.should render_template('backend/acknowledge/index')   
  end
  
end
