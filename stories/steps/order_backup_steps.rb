steps_for(:order) do
 
  Given "the list of new orders contains $total elements" do | total |
    orders = Order.new_orders
    user = Factory.create_user(:login => name)
    total.to_i.times { orders << Factory.create_order(:user_id => user.id) }
    orders.size.should == total.to_i
  end

  When "$who clicks '$action'" do | who, action |
    get "/backend/#{action}/index"
    @orders = assigns(:new_orders)
    response.should render_template('backend/acknowledge/index')   
    @response = response 
  end
  
  Then "$who sees $size_n new order$s_n and $size_d draft order$s_d" do | who, size_n, s_n, size_d, s_d |
    @orders.select{|o| !o.has_backup? }.size.should == size_n.to_i
    @orders.select{|o| o.has_backup? }.size.should == size_d.to_i
  end




end
