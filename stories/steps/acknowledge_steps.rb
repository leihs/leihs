steps_for(:acknowledge) do
  
  
  Given "the list of new orders contains $total elements" do | total |
    orders = Order.new_orders
    orders.size.should == total.to_i
  end

  Given "a new order is placed by a user named '$name'" do | name |
    user = Factory.create_user(:login => name)
    @order = Factory.create_order(:user_id => user.id)
  end
  
  Given "$total new orders are placed" do | total |
    total.to_i.times do | i |
      user = Factory.create_user(:login => "user_#{i}")
      order = Factory.create_order(:user_id => user.id)
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
    @order.add(5, Model.find_by_name(model))
    @order.save
    @order.order_lines.size.should == 1
    @order.order_lines[0].model.name.should == model
    
  end
  
  Given "$name's email address is $email" do |name, email|
    u = User.find_by_login(name)
    u.email = email
  end
  
  When "$who looks at the screen" do | who |
    get "/backend/dashboard/index"
    @response = response
  end
     
  When "$who clicks '$action'" do | who, action |
    get "/backend/#{action}/index"
    @orders = assigns(:new_orders)
    response.should render_template('backend/acknowledge/index')   
    @response = response 
  end
  
  When "$who chooses $name's order" do | who, name |
    order = @orders.find { |o| o.user.login == name }
    get "/backend/acknowledge/show/#{order.id}"
    response.should render_template('backend/acknowledge/show')
    @order = assigns(:order)
    @response = response
  end
  
  When "$who approves order" do |who|
    get "/backend/acknowledge/approve/#{@order.id}"
    @order = assigns(:order)
    @orders = assigns(:new_orders)
    @response = response
  end
  
  When "$who rejects order" do |who|
    get "/backend/acknowledge/reject/#{@order.id}"
    response.should render_template('backend/acknowledge/reject')
    @order = assigns(:order)
    @orders = assigns(:new_orders)
    @orders.should_not be_nil
    @order.should_not be_nil
    @response = response
  end
  
  When "the reason is '$reason'" do |reason|
    post "/backend/acknowledge/reject", :id => @order.id, :reason => reason
    @order = assigns(:order)
    @orders = assigns(:new_orders)
    @orders.should_not be_nil
    @order.should_not be_nil
  end
  
  When "$who changes number of items of model '$model' to $quantity" do |who, model, quantity|
    id = 0
    @order.order_lines.each do |line|
      if model == line.model.name
        id = line.id
      end
    end
    id.should > 0
    post "/backend/acknowledge/change_line", :id => id, :quantity => quantity
    response.should render_template('change_line.rjs')
  end
  
  Then "$who sees $size order$s" do | who, size, s |
    @orders.size.should == size.to_i
    @order = @orders.first
  end
  
  Then "$who sees '$what'" do | who, what |
    @response.should have_tag("a", what)
  end
  
  Then "the order was placed by a user named '$name'" do | name |
    @order.user.login.should == name
  end
  
  Then "the active tab is titled '$title'" do | title |
    @response.should have_tag("div#active_tab", title)
  end
  
  Then "$name's order is opened in tab" do |name|
    user = User.find_by_login(name)
    @order.user.login.should == user.login
    @order.user.id.should == user.id
  end
  
  Then "$who can $what order" do |who, what|
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
end
