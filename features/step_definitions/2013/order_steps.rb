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
  step "I am logged in as '#{who}' with password '#{nil}'"
  get '/order'
  model_id = Model.find_by_name(model).id
  post add_line_order_path(:model_id => model_id, :quantity => quantity, :inventory_pool_id => @inventory_pool.id)
end

When "'$user' orders another $quantity '$model' for the same time" do |user, quantity, model|
  model_id = Model.find_by_name(model).id
  post add_line_order_path(:model_id => model_id, :quantity => quantity, :inventory_pool_id => @inventory_pool.id)
  #old??# @order = assigns(:order)
end

When "'$who' orders $quantity '$model' from inventory pool $ip" do |who, quantity, model, ip|
  post "/session", :login => who #, :password => "pass"
  step "I am logged in as '#{who}' with password '#{nil}'"
  get '/order'
  model_id = Model.find_by_name(model).id
  inv_pool = InventoryPool.find_by_name(ip)
  post add_line_order_path(:model_id => model_id, :quantity => quantity, :inventory_pool_id => inv_pool.id)
  @order = @current_user.get_current_order
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

Then /^removal of this line should not be possible$/ do
  @order.remove_line(@order.lines.first, FactoryGirl.create(:user).id).should be_false
end

Given /^there is a "(.*?)" order with (\d+) lines?$/ do |order_type, no_of_lines|
  @order = FactoryGirl.create :order, :status_const => Order.const_get(order_type.to_sym), :inventory_pool => @inventory_pool
  @no_of_lines_at_start = no_of_lines.to_i
  @no_of_lines_at_start.times {@order.lines << FactoryGirl.create(:order_line, :inventory_pool => @inventory_pool)}
end

When /^one tries to delete a line$/ do
  @result_of_line_removal = @order.remove_line(@order.lines.last, FactoryGirl.create(:user).id)
end

Then /^the amount of lines decreases by one$/ do
  @order.lines.size.should eq(@no_of_lines_at_start - 1)
end

Then /^then the line is (.*)(?:\s?)deleted$/ do |not_specifier|
  @result_of_line_removal.should (not_specifier.blank? ? be_true : be_false)
end

Then /^the amount of lines remains unchanged$/ do
  @order.lines.size.should eq @no_of_lines_at_start
end

Given /^required test data for order tests existing$/ do
  @inventory_pool = FactoryGirl.create :inventory_pool
  @model_with_items = FactoryGirl.create :model_with_items
end

Given /^an inventory pool existing$/ do
  @inventory_pool = FactoryGirl.create :inventory_pool
end

Given /^an empty order of (.*) existing$/ do |allowed_type|
  allowed_type = Order.const_get(allowed_type.to_sym)
  @order = FactoryGirl.create :order, :status_const => allowed_type, :inventory_pool => @inventory_pool
end

When /^I add some lines for this order$/ do
  @quantity = 3
  @order.lines.size.should == 0
  @order.add_lines(@quantity, @model_with_items, @user, Date.tomorrow, Date.tomorrow + 1.week, @inventory_pool)
end

Then /^the size of the order should increase exactly by the amount of lines added$/ do
  @order.reload.lines.size.should == @quantity
  @order.valid?.should be_true
end

Given /^an order with lines existing$/ do
  @order = FactoryGirl.create :order_with_lines, :inventory_pool => @inventory_pool
end

Given /^a borrowing user existing$/ do
  @borrowing_user = LeihsFactory.create_user({:login => 'foo', :email => 'foo@example.com'}, {:password => 'barbarbar'})
end

When /^I approve the order of the borrowing user$/ do
  @order.approve("That will be fine.", Persona::get("Ramon"))
  @order.is_approved?.should be_true
end

Then /^the borrowing user gets one confirmation email$/ do
  @emails = ActionMailer::Base.deliveries
  @emails.count.should == 1
end

Then /^the subject of the email is "(.*?)"$/ do |arg1|
  @emails[0].subject.should == "[leihs] Reservation Confirmation"
end

When /^the order is submitted with the purpose description "(.*?)"$/ do |purpose|
  @purpose = purpose
  @order.submit(@purpose)
end

Then /^each line associated with the order must have the same purpose description$/ do
  @order.lines.each do |l|
    l.purpose.description.should == @purpose
  end
end
