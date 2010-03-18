Given "the list of new orders contains $total elements" do | total |
  orders = Order.submitted
  orders.size.should == total.to_i
end

Given "the new order is submitted" do
  @order.submit
end

Given "$total new orders are placed" do | total |
  total.to_i.times do | i |
    user = Factory.create_user(:login => "user_#{i}")
    order = Factory.create_order(:user_id => user.id).submit
  end
end

Given /it asks for ([0-9]+) items of model '(.*)'/ do |number, model|
  @order.add_line(number, Model.find_by_name(model), 1)
  @order.log_history("user submits order", 1)
  @order.save
  @order.has_changes?.should == false
  @order.order_lines[0].model.name.should == model
end

Given "$name's email address is $email" do |name, email|
  u = User.find_by_login(name)
  u.update_attributes(:email => email)
  u.language = Language.find(2)
  u.save
end

When "$who looks at the screen" do | who |
  get backend_inventory_pool_path(@inventory_pool)
  @response = response
end
   
When "$who clicks on 'acknowledge'" do | who |
  get backend_inventory_pool_acknowledge_path(@inventory_pool)
  @orders = assigns(:orders)
#0402#  
  response.should render_template('backend/acknowledge/index')
  @response = response 
end

When "$who chooses $name's order" do | who, name |
  order = @orders.detect { |o| o.user.login == name }
  get backend_inventory_pool_user_acknowledge_path(@inventory_pool, order.user, order)
  response.should render_template('backend/acknowledge/show')
  @order = assigns(:order)
  @response = response
end


When "$who rejects order with reason '$reason'" do |who, reason|
  post reject_backend_inventory_pool_user_acknowledge_path(@inventory_pool, @order.user, @order, :comment => reason)
  @order = assigns(:order)
  @orders.should_not be_nil
  @order.should_not be_nil
  @response = response
  response.redirect_url.should == "http://www.example.com/backend/inventory_pools/#{@inventory_pool.id}/acknowledge"
end

When "$who changes number of items of model '$model' to $quantity" do |who, model, quantity|
  id = find_line(model).id
  id.should > 0
  post change_line_quantity_backend_inventory_pool_user_acknowledge_path(@inventory_pool, @order.user, @order, :order_line_id => id, :quantity => quantity)
  response.should render_template('backend/acknowledge/change_line_quantity')
  @order = assigns(:order)
  @order.has_changes?.should == true
  find_line(model).quantity.should == 4
end

When "$who adds $quantity item '$model'" do |who, quantity, model|
  model_id = Model.find_by_name(model).id
  post add_line_backend_inventory_pool_user_acknowledge_path(@inventory_pool, @order.user, @order, :model_id => model_id, :quantity => quantity)
  @order = assigns(:order)
  @order.order_lines.each do | line |
    line.model.should_not be_nil
  end
  @response = response #new#
  @response.redirect_url.should include("backend/inventory_pools/#{@inventory_pool.id}/users/#{@order.user.id}/acknowledge/#{@order.id}")
end


When "$who adds a personal message: '$message'" do |who, message|
  @comment = message
end

When "$who chooses 'swap' on order line '$model'" do |who, model|
  line = find_line(model)
  get swap_model_line_backend_inventory_pool_user_acknowledge_path(@inventory_pool, @order.user, @order, :line_id => line.id)
  @order_line_id = line.id
  @response = response    
end

When "$who searches for '$model'" do |who, model|
  get backend_inventory_pool_models_path(@inventory_pool, :query => model, :user_id => @order.user_id,
                                        :source_path => swap_model_line_backend_inventory_pool_user_acknowledge_path(@inventory_pool, @order.user, @order, :line_id => @order_line_id),
                                        :order_line_id => @order_line_id )
  @models = assigns(:models)
  @models.should_not be_nil
end

When "$who selects '$model'" do |who, model|
  model_id = Model.first(:conditions => { :name => model}).id
  post swap_model_line_backend_inventory_pool_user_acknowledge_path(@inventory_pool, @order.user, @order, :line_id => @order_line_id, :model_id => model_id)
  @order = assigns(:order)
  @order.should_not be_nil
end

# NOTE this is not actually what he sees on the first page, but the total submitted orders
Then /^(.*) sees ([0-9]+) order(s?)$/ do | who, size, s |
#old#0402  @orders.total_entries.should == size.to_i
  When "#{who} clicks on 'acknowledge'" unless assigns(:orders)
  assigns(:orders).total_entries.should == size.to_i
end

Then "$who sees '$what'" do | who, what |
  @response.should have_tag("a", what)
end

Then "the order was placed by a user named '$name'" do | name |
  @order = @orders.first if @orders.size == 1 #temp#
  @order.user.login.should == name
end

Then "he sees the '$title' list" do | title |
  response.should render_template("backend/#{title}/index")
end

Then "$name's order is shown" do |name|
  user = User.find_by_login(name)
  @order.user.login.should == user.login
  @order.user.id.should == user.id
end

Then "$who can $what" do |who, what|
  @response.should have_tag("a", what)
end

Then "$email receives an email" do |email|
  ActionMailer::Base.deliveries.size.should == 1
  @mail = ActionMailer::Base.deliveries[0]  
  @mail.to[0].should == email
  ActionMailer::Base.deliveries.clear
end

Then "its subject is '$subject'" do |subject|
  @mail.subject.should == subject
end

Then "it contains information '$line'" do |line|
  @mail.body.should match(Regexp.new(line))
end

Then "Swap Item screen opens" do 
  @response.redirect_url.should include("/backend/inventory_pools/#{@inventory_pool.id}/models?layout=modal&order_line_id=#{@order_line_id}&source_path=%2Fbackend%2Finventory_pools%2F#{@inventory_pool.id}%2Fusers%2F#{@order.user.id}%2Facknowledge%2F#{@order.id}%2Fswap_model_line%3Fline_id%3D#{@order_line_id}")
end

Then "a choice of $size item appears" do |size|
  @models.size.should == size.to_i
end

Then "$who sees $quantity items of model '$model'" do |who, quantity, model|
  line = find_line(model)
  line.should_not be_nil
  line.quantity.should == quantity.to_i
end
