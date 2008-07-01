steps_for(:hand_over) do


  Given "the list of approved orders contains $total elements" do | total |
    orders = Order.approved_orders
    user = Factory.create_user
    total.to_i.times { orders << Factory.create_order(:user_id => user.id, :status_const => Order::APPROVED) }
    orders.size.should == total.to_i
  end

  # TODO test as Given or refactor to order_test 
  When "a new order is placed by a user named '$who'" do | who |
    user = Factory.create_user(:login => who)
    @order = Factory.create_order({:user_id => user.id})    
  end


  # TODO test as Given or refactor to order_test 
  When "$who asks for $quantity '$what' from $from" do | who, quantity, what, from |
    @order.order_lines << Factory.create_order_line(:model_name => what,
                                                    :quantity => quantity,
                                                    :start_date => from)
    @order.save                                                
  end

  # OPTIMIZE see availability_inventory_pool_steps.rb
  When "the new order is submitted" do
    @order.submit
  end
  
  When "$who approves the order" do | who |
    post "/backend/acknowledge/approve", :id => @order.id, :comment => "test comment"
    @order = assigns(:order)
    @order.should_not be_nil
    @contract = @order.user.reload.current_contract(@order.inventory_pool)
    @contract.should_not be_nil
  end


  When "$who clicks '$action'" do | who, action |
    get "/backend/#{action}/index"
    @visits = assigns(:visits)
    response.should render_template("backend/#{action}/index")
  end
  
  Then "he sees $total line$s with a total quantity of $quantity" do | total, s, quantity |
     @visits.size.should == total.to_i
     s = 0
     @visits.each {|v| s += v.quantity }
     s.should == quantity.to_i 
  end

###############################################

  Then "line $line has a quantity of $quantity for user '$who'" do | line, quantity, who |
    @visits[line.to_i - 1].quantity.should == quantity.to_i
    @visits[line.to_i - 1].user.login.should == who
  end

###############################################


  When "$who chooses one line" do | who |
    line = @visits.first
    get "/backend/hand_over/show/#{line.user.id}"
    response.should render_template('backend/hand_over/show')
    @contract = assigns(:contract)
  end

  Then "a new contract is generated" do
    @contract.nil?.should == false
  end

  Then "he sees $size contract line$s for all approved order lines" do | size, s |
    @contract.contract_lines.size.should == size.to_i
  end

###############################################

  
end
