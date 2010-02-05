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
  @original_order = @order
  @original_order.has_backup?.should == false
  @order.order_lines.size.should == size.to_i
end

When "$who chooses the order" do | who |
  @order.has_backup?.should == false
  sleep 1
  get backend_inventory_pool_user_acknowledge_path(@inventory_pool, @order.user, @order)
  response.should render_template('backend/acknowledge/show')
  @order = assigns(:order)
  sleep 1
  @order.has_backup?.should == true
  @order.backup.created_at.should >= @order.histories.first.created_at if @order.histories.first
end

When "$who deletes $size order line$s" do | who, size, s |
  @lines = @order.order_lines[0, size.to_i].collect(&:id)
  delete remove_lines_backend_inventory_pool_user_acknowledge_path(@inventory_pool, @order.user, @order, :lines => @lines)
  @order = assigns(:order)
end

Then "the order has $size order line$s" do | size, s |
  @order.order_lines.size.should == size.to_i  
end

# NOTE used as Given as well
Then "the order has $size changes" do | size |
  @order.histories.size.should == size.to_i
end

When "$who restores the order" do | who |
  post restore_backend_inventory_pool_user_acknowledge_path(@inventory_pool, @order.user, @order)
  @order = assigns(:order)
end

Then "the restored order has the same $size order line$s as the original" do | size, s |
  @order.order_lines.size.should == size.to_i 
  @original_order.order_lines.size.should == size.to_i
  equal_collections?(@order.order_lines, @original_order.order_lines).should == true
end

Then "the restored order has the same $size change$s as the original" do | size, s |
  @order.reload
  @order.histories.size.should == size.to_i 
  @order.histories.should == @original_order.histories
end

Then "is redirected to '$action'" do | action |
  get send("backend_inventory_pool_#{action}_path", @inventory_pool)
  @orders = assigns(:orders)
  response.should render_template('backend/acknowledge/index')   
end

###############################################

Given "lending_manager works on one order" do
  user = Factory.create_user(:login => "Joe")
  order = Factory.create_order({:user_id => user.id}, {:order_lines => 3})
  order.submit
  get backend_inventory_pool_user_acknowledge_path(@inventory_pool, order.user, order)
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
