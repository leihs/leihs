steps_for(:hand_over) do

  
  Given "the list of approved orders contains $total elements" do | total |
    orders = Order.approved_orders
    user = Factory.create_user(:login => name)
    total.to_i.times { orders << Factory.create_order(:user_id => user.id, :status_const => Order::APPROVED) }
    orders.size.should == total.to_i
  end

  When "a new order is placed by a user named '$who'" do | who |
    user = Factory.create_user(:login => who)
    @order = Factory.create_order({:user_id => user.id})    
  end


  When "he asks for $quantity '$what' from $from" do | quantity, what, from |
    @order.order_lines << Factory.create_order_line(:model_name => :what,
                                                    :quantity => quantity,
                                                    :start_date => from)
    @order.save                                                
  end
  
  When "an inventory_manager approves the order" do
    post "/backend/acknowledge/approve", :id => @order.id, :comment => "test comment"
    @order = assigns(:order)
    @order.should_not be_nil
  end


  When "$who clicks '$action'" do | who, action |
    get "/backend/#{action}/index"
    @grouped_lines = assigns(:grouped_lines)
    response.should render_template("backend/#{action}/index")
  end
  
  Then "he sees $total line$s with a total quantity of $quantity" do | total, s, quantity |
      if @grouped_lines.size != total.to_i
        @grouped_lines.each do |l|
          puts l.start_date.to_s  
        end
      end
     @grouped_lines.size.should == total.to_i
     s = 0
     @grouped_lines.each {|l| s += l.quantity }
     s.should == quantity.to_i 
  end

  Then "line $line has a quantity of $quantity for user '$who'" do | line, quantity, who |
    @grouped_lines[line.to_i - 1].quantity.should == quantity.to_i
    @grouped_lines[line.to_i - 1].user_login.should == who
  end

###############################################

  
end
