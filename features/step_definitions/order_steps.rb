Given "a new order is placed by a user named '$who'" do | who |
  user = Factory.create_user(:login => who)
  @order = Factory.create_order(:user_id => user.id)
end

Given "the list of submitted orders contains $total elements" do | total |
  Order.submitted.count.should == 0
  user = Factory.create_user
  total.to_i.times { Factory.create_order(:user_id => user.id).submit }
  Order.submitted.count.should == total.to_i
end

Given "there are no orders and no contracts" do
  Order.destroy_all
  Contract.destroy_all
end

When "$who chooses one order" do | who |
  order = @orders.first
  get backend_inventory_pool_user_acknowledge_path(@inventory_pool, order.user, order)
  response.should render_template('backend/acknowledge/show')
  @order = assigns(:order)
end

###############################################

# TODO test as Given 
When "$who asks for $quantity '$what' from $from" do | who, quantity, what, from |
  @order.order_lines << Factory.create_order_line(:model_name => what,
                                                  :quantity => quantity,
                                                  :start_date => from)
  @order.save                                                
end

When "$who approves order" do |who|
  @comment ||= ""
  @order.approvable?.should be_true
#0402  post "/session", :login => @last_manager_login_name #new#
  post approve_backend_inventory_pool_user_acknowledge_path(@inventory_pool, @order.user, @order, :comment => @comment)
  @order = assigns(:order)
  @order.should_not be_nil
  @order.approvable?.should be_false
  response.redirect_url.should == "http://www.example.com/backend/inventory_pools/#{@inventory_pool.id}/acknowledge"
  @response = response
end


When "$who rejects order" do |who|
  @comment ||= ""
  post reject_backend_inventory_pool_user_acknowledge_path(@inventory_pool, @order.user, @order, :comment => @comment)
  @order = assigns(:order)
  response.redirect_url.should == "http://www.example.com/backend/inventory_pools/#{@inventory_pool.id}/acknowledge"
end


When "he deletes order" do
  delete backend_inventory_pool_user_acknowledge_path(@inventory_pool, @order.user, @order)
  @order = assigns(:order)
  response.redirect_url.should == "http://www.example.com/backend/inventory_pools/#{@inventory_pool.id}/acknowledge"
end
