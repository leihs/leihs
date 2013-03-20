When "$who clicks on 'acknowledge'" do | who |
  get backend_inventory_pool_acknowledge_index_path(@inventory_pool)
  @orders = assigns(:orders)
#0402#  
  @response = response 
end

When "$who chooses $name's order" do | who, name |
  order = @orders.detect { |o| o.user.login == name }
  get backend_inventory_pool_acknowledge_path(@inventory_pool, order)
  response.should render_template('backend/acknowledge/show')
  @order = assigns(:order)
  @response = response
end

When "$who rejects order with reason '$reason'" do |who, reason|
  post reject_backend_inventory_pool_acknowledge_path(@inventory_pool, @order, :comment => reason)
  @order = assigns(:order)
  @orders.should_not be_nil
  @order.should_not be_nil
  @response = response
  response.redirect_url.should == "http://www.example.com/backend/inventory_pools/#{@inventory_pool.id}/acknowledge"
end

When "$who changes number of items of model '$model' to $quantity" do |who, model, quantity|
  pending
=begin #old leihs#  
  id = find_line(model).id
  id.should > 0
  post change_line_quantity_backend_inventory_pool_acknowledge_path(@inventory_pool, @order, :order_line_id => id, :quantity => quantity)
  response.should render_template('backend/acknowledge/change_line_quantity')
  @order = assigns(:order)
  @order.has_changes?.should == true
  find_line(model).quantity.should == quantity.to_i
=end
end

When "$who adds $quantity item '$model'" do |who, quantity, model|
  model_id = Model.find_by_name(model).id
  post add_line_backend_inventory_pool_acknowledge_path(@inventory_pool, @order, :model_id => model_id, :quantity => quantity)
  @order = assigns(:order)
  @order.order_lines.each do | line |
    line.model.should_not be_nil
  end
  @response = response #new#
  @response.redirect_url.should include("backend/inventory_pools/#{@inventory_pool.id}/acknowledge/#{@order.id}")
end


When "$who adds a personal message: '$message'" do |who, message|
  @comment = message
end

When "$who chooses 'swap' on order line '$model'" do |who, model|
  line = find_line(model)
  get swap_model_line_backend_inventory_pool_acknowledge_path(@inventory_pool, @order, :line_id => line.id)
  @order_line_id = line.id
  @response = response    
end

When "$who searches for '$model'" do |who, model|
  get backend_inventory_pool_inventory_path(@inventory_pool, :query => model, :user_id => @order.user_id,
                                        :source_path => swap_model_line_backend_inventory_pool_acknowledge_path(@inventory_pool, @order, :line_id => @order_line_id),
                                        :order_line_id => @order_line_id )
  @models = assigns(:models)
  @models.should_not be_nil
end

When "$who selects '$model'" do |who, model|
  model_id = Model.where(:name => model).first.id
  post swap_model_line_backend_inventory_pool_acknowledge_path(@inventory_pool, @order, :line_id => @order_line_id, :model_id => model_id)
  @order = assigns(:order)
  @order.should_not be_nil
end

Then /^(.*) see(s)? ([0-9]+) order(s?)$/ do | who, foo, size, s |
  page.all(".table-overview .fresh").count.should == 1
end

# NOTE this is not actually what he sees on the first page, but the total submitted orders
#Then /^(.*) sees ([0-9]+) order(s?)$/ do | who, size, s |
##old#0402  @orders.total_entries.should == size.to_i
#  When "#{who} clicks on 'acknowledge'" unless assigns(:orders)
#  assigns(:orders).total_entries.should == size.to_i
#end

#Then "$name's order is shown" do |name|
#  # TODO: we should be passing through the controller/view here!
#  user = User.find_by_login(name)
#  @order.user.login.should == user.login
#  @order.user.id.should == user.id
#end

Then "Swap Item screen opens" do 
  @response.redirect_url.should include("/backend/inventory_pools/#{@inventory_pool.id}/models?layout=modal&order_line_id=#{@order_line_id}&source_path=%2Fbackend%2Finventory_pools%2F#{@inventory_pool.id}%2Facknowledge%2F#{@order.id}%2Fswap_model_line%3Fline_id%3D#{@order_line_id}")
end

Then "a choice of $size item appears" do |size|
  @models.size.should == size.to_i
end

Then "$who sees $quantity items of model '$model'" do |who, quantity, model|
  line = find_line(model)
  line.should_not be_nil
  line.quantity.should == quantity.to_i
end

Then "all '$what' order lines are marked as invalid" do |what|
  # TODO: VERY ugly - we need have_tag "td.valid_false"
  @response.body.should =~ /valid_false/
end

Then "the order should not be approvable$reason" do |reason|
  @order.approvable?.should == false
end

Then "the order should be approvable$reason" do |reason|
  @order.approvable?.should == true
end

###############################################

require 'spec/mocks'

Given "email delivery is broken" do
  Notification.stub!(:order_approved).and_throw(:mail_is_borken)
end

Then "email delivery is working again" do
  Spec::Mocks::Space#reset_all
end

###############################################
