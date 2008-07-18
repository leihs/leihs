steps_for(:order_backup) do
 
  
  When "$who clicks '$action'" do | who, action |
    get "/backend/#{action}/index"
    @orders = assigns(:submitted_orders)
    response.should render_template('backend/acknowledge/index')
  end
  
  Then "$who sees $size_n submitted order$s_n and $size_d draft order$s_d" do | who, size_n, s_n, size_d, s_d |
    @orders.select{|o| !o.has_backup? }.size.should == size_n.to_i
    @orders.select{|o| o.has_backup? }.size.should == size_d.to_i
  end

  Then "a backup for the order is generated" do
    @order.has_backup?.should == true
  end

###############################################

  Given "a submitted order with $size order lines" do | size |
    user = Factory.create_user(:login => "Joe")
    @order = Factory.create_order({:user_id => user.id}, {:order_lines => size.to_i})
    @order.submit
# debug here
#puts; puts "==="; puts "Histories crated_at:"; @order.histories.each { |h| puts; puts h.text; puts h.created_at; puts "%10.5f" % h.created_at.to_f }; puts "==="
    @original_order = @order
    @original_order.has_backup?.should == false
    @order.order_lines.size.should == size.to_i
  end

  Given "the order has $size changes" do | size |
    @order.histories.size.should == size.to_i
  end

  When "$who chooses the order" do | who |
    @order.has_backup?.should == false
    get "/backend/acknowledge/show/#{@order.id}"
    response.should render_template('backend/acknowledge/show')
    @order = assigns(:order)
    @order.has_backup?.should == true
# debug here    
#puts; puts "==="; puts "Backup created at:"; puts @order.backup.created_at; puts "%10.5f" % @order.backup.created_at.to_f; puts "==="
  end

  When "$who deletes $size order line$s" do | who, size, s |
#old#    size.to_i.times { @order.remove_line(@order.order_lines.first.id, @order.user.id) }
    @lines = @order.order_lines[0, size.to_i].collect(&:id)
    post "/backend/acknowledge/remove_lines", :id => @order.id, :lines => @lines
    @order = assigns(:order)
  end

  Then "the order has $size order line$s" do | size, s |
    @order.order_lines.size.should == size.to_i  
  end

  Then "the order has $size changes" do | size |
    @order.histories.size.should == size.to_i
  end
  
  When "$who restores the order" do | who |
#old#    @order.from_backup
    post "/backend/acknowledge/restore", :id => @order.id
    @order = assigns(:order)
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
    @orders = assigns(:submitted_orders)
    response.should render_template('backend/acknowledge/index')   
  end

###############################################
  
  Given "inventory_manager works on one order" do
    user = Factory.create_user(:login => "Joe")
    order = Factory.create_order({:user_id => user.id}, {:order_lines => 3})
    order.submit
    get "/backend/acknowledge/show/#{order.id}"
    response.should render_template('backend/acknowledge/show')
    @order = assigns(:order)
    @order.has_backup?.should == true
  end
    
  Then "the order doesn't have a backup anymore" do
    @order.has_backup?.should == false
  end

  
###############################################

  Then "the order and the backup are deleted" do
    @order.frozen?.should == true
    Order.exists?(@order.id).should == false
    @order.backup.frozen?.should == true
    Backup::Order.exists?(@order.backup.id).should == false
  end
  
end
