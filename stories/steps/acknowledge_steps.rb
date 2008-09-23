steps_for(:acknowledge) do

  
  Given "the list of new orders contains $total elements" do | total |
    orders = Order.submitted_orders
    orders.size.should == total.to_i
  end

  Given "a new order is placed by a user named '$name'" do | name |
    user = Factory.create_user({:login => name}, {:role => "student"})
    @order = Factory.create_order(:user_id => user.id)
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
  
  Given "a model '$model' exists" do | model |
    Factory.create_model(:name => model)
  end
  
  Given "$number items of model '$model' exist" do |number, model|
    number.to_i.times do | i |
      Factory.create_item(:model_id => Model.find_by_name(model).id)
    end
  end
  
  Given "it asks for $number items of model '$model'" do |number, model|
    @order.add_line(number, Model.find_by_name(model), 1)
    @order.log_history("user submits order", 1)
    @order.save
    @order.has_changes?.should == false
    @order.order_lines[0].model.name.should == model
  end
  
  Given "$name's email address is $email" do |name, email|
    u = User.find_by_login(name)
    u.update_attribute(:email, email)
  end
  
  When "$who looks at the screen" do | who |
    get "/backend/dashboard/index"
    @response = response
  end
     
  When "$who clicks '$action'" do | who, action |
    get "/backend/#{action}/index"
    @orders_size = assigns(:to_acknowledge_size)
    @orders = assigns(:submitted_orders)
    response.should render_template('backend/acknowledge/index')
    @response = response 
  end
  
  When "$who chooses $name's order" do | who, name |
    order = @orders.detect { |o| o.user.login == name }
    get "/backend/acknowledge/show/#{order.id}"
    response.should render_template('backend/acknowledge/show')
    @order = assigns(:order)
    @response = response
  end
  
  
  When "$who rejects order with reason '$reason'" do |who, reason|
    post "/backend/acknowledge/reject", :id => @order.id, :comment => reason
    @order = assigns(:order)
    @orders_size = assigns(:to_acknowledge_size)
    @orders.should_not be_nil
    @order.should_not be_nil
    @response = response
    response.redirect_url.should == 'http://www.example.com/backend/acknowledge'
    
  end
  
  When "$who changes number of items of model '$model' to $quantity" do |who, model, quantity|
    id = find_line(model).id
    id.should > 0
    post "/backend/acknowledge/change_line", :id => @order.id, :order_line_id => id, :quantity => quantity
    response.should render_template('backend/acknowledge/change_line')
    @order = assigns(:order)
    @order.has_changes?.should == true
    find_line(model).quantity.should == 4
  end
  
  When "$who adds $quantity item '$model'" do |who, quantity, model|
    model_id = Model.find_by_name(model).id
    post "/backend/acknowledge/add_line", :id => @order.id, :model_id => model_id, :quantity => quantity
    @order = assigns(:order)
    @order.order_lines.each do | line |
      line.model.should_not be_nil
    end
    
    @response.redirect_url.should include("backend/acknowledge/show/#{@order.id}")
  end
  
  
  When "$who adds a personal message: '$message'" do |who, message|
    @comment = message
  end

  When "$who chooses 'swap' on order line '$model'" do |who, model|
    line = find_line(model)
    get "/backend/acknowledge/swap_model_line", :id => @order.id, :line_id => line.id
    @order_line_id = line.id
    @response = response    
  end
  
  When "$who searches for '$model'" do |who, model|
    post "/backend/models/search", :query => model, :source_controller => "acknowledge", :source_action => "swap_model_line"
    @search_result = assigns(:search_result)
    @search_result.should_not be_nil
  end
  
  When "$who selects '$model'" do |who, model|
    model_id = Model.find(:first, :conditions => { :name => model}).id
    post "/backend/acknowledge/swap_model_line", :id => @order.id, :line_id => @order_line_id, :model_id => model_id
    @order = assigns(:order)
    @order.should_not be_nil
  end
  
  Then "$who sees $size order$s" do | who, size, s |
    get "/backend/acknowledge/index"
    @orders_size = assigns(:to_acknowledge_size)
    
    @orders_size.should == size.to_i
  end
  
  Then "$who sees '$what'" do | who, what |
    @response.should have_tag("a", what)
  end
  
  Then "the order was placed by a user named '$name'" do | name |
    @order = @orders.first if @orders.size == 1 #temp#
    @order.user.login.should == name
  end
  
  Then "the active tab is titled '$title'" do | title |
    @response.should have_tag("li.active", title)
  end
  
  Then "$name's order is opened in tab" do |name|
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
    @response.redirect_url.should include("/backend/models/search?document_id=#{@order.id}&line_id=#{@order_line_id}")
  end
  
  Then "a choice of $size item appears" do |size|
    @search_result.size.should == size.to_i
  end
  
  Then "$who sees $quantity items of model '$model'" do |who, quantity, model|
    line = find_line(model)
    line.should_not be_nil
    line.quantity.should == quantity.to_i
  end
end
