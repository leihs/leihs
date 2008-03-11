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
  
  Given "a type '$type' exists" do | type |
    Factory.create_type(:name => type)
  end
  
  Given "$number items of type '$type' exist" do |number, type|
    number.to_i.times do | i |
      Factory.create_item(:type_id => Type.find_by_name(type).id)
    end
  end
  
  Given "it asks for $number items of type '$type'" do |number, type|
    @order.add(5, Type.find_by_name(type))
    @order.save
    @order.order_lines.size.should == 1
    @order.order_lines[0].type.name.should == type
    
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
