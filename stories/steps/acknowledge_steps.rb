steps_for(:acknowledge) do
   
  Given "the list of new orders contains $total elements" do | total |
    orders = Order.new_orders
    orders.size.should == total.to_i
  end

  Given "a new order is placed by a user named '$name'" do | name |
    user = Factory.create_user(:login => name)
    order = Factory.create_order(:user_id => user.id)
  end
  
  Given "$total new orders are placed" do | total |
    total.to_i.times do | i |
      user = Factory.create_user(:login => "user_#{i}")
      order = Factory.create_order(:user_id => user.id)
    end
  end
  
  When "the inventory_manager clicks '$action'" do | action |
    get "/#{action}/index"
    @orders = assigns(:new_orders)
    response.should render_template('acknowledge/index')    
  end
  
  Then "$who sees 1 order" do | who |

    @orders.size.should == 1
    @order = @orders[0]
  end
  
  Then "the name of the user is '$name'" do | name |
    @order.user.login.should == name
  end
end
