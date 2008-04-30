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
#TODO wait?
# debug here
puts; puts "==="; puts "Histories crated_at:"; @order.histories.each { |h| puts; puts h.text; puts h.created_at; puts "%10.5f" % h.created_at.to_f }; puts "==="
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
# debug here    
puts; puts "==="; puts "Backup created at:"; puts @order.backup.created_at; puts "%10.5f" % @order.backup.created_at.to_f; puts "==="
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

###############################################
  
  Given "inventory_manager works on one order" do
    user = Factory.create_user(:login => "Joe")
    order = Factory.create_order({:user_id => user.id}, {:order_lines => 3})
    get "/backend/acknowledge/show/#{order.id}"
    response.should render_template('backend/acknowledge/show')
    @order = assigns(:order)
    @order.has_backup?.should == true
  end
  
  When "he approves order" do
    post "/backend/acknowledge/approve/#{@order.id}"
    @order = assigns(:order)
    response.redirect_url.should == 'http://www.example.com/backend/acknowledge'
  end
  
  Then "the order doesn't have a backup anymore" do
    @order.has_backup?.should == false
  end

  
###############################################
  
  When "he rejects order" do
    post "/backend/acknowledge/reject/#{@order.id}"
    @order = assigns(:order)
    response.redirect_url.should == 'http://www.example.com/backend/acknowledge'
  end
  

###############################################
  
  When "he deletes order" do
    post "/backend/acknowledge/destroy/#{@order.id}"
    @order = assigns(:order)
    response.redirect_url.should == 'http://www.example.com/backend/acknowledge'
  end

  Then "the order and the backup are deleted" do
    @order.frozen?.should == true
    Order.exists?(@order.id).should == false
    @order.backup.frozen?.should == true
    Backup::Order.exists?(@order.backup.id).should == false
  end
  
end
