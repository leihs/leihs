Given /there is (only )?an order by (a customer named )?'(.*)'/ do | only, bla, who |
  step "there are no orders" if only
  firstname, lastname = who
  firstname, lastname = who.split(" ") if who.include?(" ")
  
  if @inventory_pool
    @user = LeihsFactory.create_user( { :login => who, :firstname => firstname, :lastname => lastname }, { :inventory_pool => @inventory_pool } )
    @order = LeihsFactory.create_order( :user_id => @user.id, :inventory_pool => @inventory_pool )    
  else
    @user = LeihsFactory.create_user(:login => who, :firstname => firstname, :lastname => lastname)
    @order = LeihsFactory.create_order({:user_id => @user.id})    
  end
end

# TODO perform real post 
When "'$who' places a new order" do | who |
  step "there is an order by '#{who}'"
  post "/session", :login => who #new#
end

Given "the order was submitted" do
  @order.submit
  @order.status_const.should == Order::SUBMITTED
end

When "he submits the new order" do
  @order = @current_user.get_current_order
  @order.status_const.should == Order::UNSUBMITTED
  post submit_order_path
  @order = @order.reload
  @order.status_const.should == Order::SUBMITTED
end

Given "there are only $total orders" do | total |
  total.to_i.times do | i |
    user = LeihsFactory.create_user(:login => "user_#{i}")
    order = LeihsFactory.create_order(:user_id => user.id).submit
  end
end

Given "the list of submitted orders contains $total elements" do | total |
  Order.submitted.count.should == 0
  user = LeihsFactory.create_user
  total.to_i.times { LeihsFactory.create_order(:user_id => user.id).submit }
  Order.submitted.count.should == total.to_i
end

Given "there are no orders" do
  Order.destroy_all
end

Given "there are no contracts" do
  Contract.destroy_all
end

Given "there are no new orders" do
  Order.delete_all :status_const => Order::SUBMITTED
end

Given /it asks for ([0-9]+) item(s?) of model '(.*)'/ do |number, plural, model|
  @order.add_lines(number, Model.find_by_name(model), @user)
  @order.log_history("user submits order", 1)
  @order.save
  @order.has_changes?.should == false
  @order.order_lines[0].model.name.should == model
end

When "he asks for another $number items of model '$model'" do |number, model|
	Given "it asks for #{number} items of model '#{model}'"
end

When "$who chooses one order" do | who |
  order = @orders.first
  get backend_inventory_pool_acknowledge_path(@inventory_pool, order)
  response.should render_template('backend/acknowledge/show')
  #old??# @order = assigns(:order)
end

When "I choose to process $who's order" do | who |
  el = page.find(:xpath, "//tr[contains(.,'#{who}')]")
  el.click_link("View and edit")
end

Then "$name's order is shown" do |who|
  # body =~ /.*Order.*Joe.*/
  page.should have_xpath("//body[contains(.,'#{who}')][contains(.,'Order')]")
end

###############################################

# TODO test as Given 
When "$who asks for $quantity '$what' from $from" do | who, quantity, what, from |
  from = Date.today.strftime("%d.%m.%Y") if from == "today"
  @order.order_lines << LeihsFactory.create_order_line(:model_name => what,
                                                  :quantity => quantity,
                                                  :start_date => from,
						  :inventory_pool => @inventory_pool)
  @order.save                                                
end


#When "$who approves order" do |who|
#  @comment ||= ""
#  @order.approvable?.should be_true
##0402  post "/session", :login => @last_manager_login_name #new#
#  post approve_backend_inventory_pool_acknowledge_path(@inventory_pool, @order, :comment => @comment)
#  @order = assigns(:order)
#  @order.should_not be_nil
#  @order.approvable?.should be_false
#  response.redirect_url.should == "http://www.example.com/backend/inventory_pools/#{@inventory_pool.id}/acknowledge"
#  @response = response
#end

When "$who rejects order" do |who|
  @comment ||= ""
  post reject_backend_inventory_pool_acknowledge_path(@inventory_pool, @order, :comment => @comment)
  #old??# @order = assigns(:order)
  response.redirect_url.should == "http://www.example.com/backend/inventory_pools/#{@inventory_pool.id}/acknowledge"
end


When "he deletes order" do
  @order = @user.get_current_order
  delete backend_inventory_pool_acknowledge_path(@inventory_pool, @order)
  response.redirect_url.should == "http://www.example.com/backend/inventory_pools/#{@inventory_pool.id}/acknowledge"
end

When "'$who' orders $quantity '$model'" do |who, quantity, model|
  post "/session", :login => who #, :password => "pass"
  step "I am \"%s\"" % who
  get '/order'
  model_id = Model.find_by_name(model).id
  post add_line_order_path(:model_id => model_id, :quantity => quantity)
end

When "'$user' orders another $quantity '$model' for the same time" do |user, quantity, model|
  model_id = Model.find_by_name(model).id
  post add_line_order_path(:model_id => model_id, :quantity => quantity)
  #old??# @order = assigns(:order)
end

When "'$who' orders $quantity '$model' from inventory pool $ip" do |who, quantity, model, ip|
  post "/session", :login => who #, :password => "pass"
  step "I am \"%s\"" % who
  get '/order'
  model_id = Model.find_by_name(model).id
  inv_pool = InventoryPool.find_by_name(ip)
  post add_line_order_path(:model_id => model_id, :quantity => quantity, :inventory_pool_id => inv_pool.id)
  @order = @user.get_current_order
end

When "'$who' searches for '$model' on frontend" do |who, model|
  post "/session", :login => who #, :password => "pass"
  response = get search_path(:term => model, :format => :json)
  @models_json = JSON.parse(response.body)
end

Then /([0-9]+) order(s?) exist(s?) for inventory pool (.*)/ do |size, s1, s2, ip|
  inventory_pool = InventoryPool.find_by_name(ip)
  @orders = inventory_pool.orders.submitted
  @orders.size.should == size.to_i
end

Then "customer '$user' gets notified that his order has been submitted" do |who|
  user = LeihsFactory.create_user({:login => who })
  user.notifications.size.should == 1
  user.notifications.first.title = "Order submitted"
end

Then "the order was placed by a customer named '$name'" do | name |
  page.find(".table-overview .fresh").should have_content(name)
end

