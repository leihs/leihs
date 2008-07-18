steps_for(:order) do
 
  
  Given "the list of submitted orders contains $total elements" do | total |
    orders = Order.submitted_orders
    orders.size.should == 0
    user = Factory.create_user
    total.to_i.times { orders << Factory.create_order(:user_id => user.id).submit }
    orders.size.should == total.to_i
  end

  When "$who chooses one order" do | who |
    order = @orders.first
    get "/backend/acknowledge/show/#{order.id}"
    response.should render_template('backend/acknowledge/show')
    @order = assigns(:order)
  end

###############################################

  When "$who approves order" do |who|
    @comment ||= ""
    @order.approvable?.should be_true
    post "/backend/acknowledge/approve", :id => @order.id, :comment => @comment
    @order = assigns(:order)
    @order.should_not be_nil
    @order.approvable?.should be_false
    @orders_size = assigns(:to_acknowledge_size)
    response.redirect_url.should == 'http://www.example.com/backend/acknowledge'
    @response = response
  end


  When "$who rejects order" do |who|
    @comment ||= ""
    post "/backend/acknowledge/reject", :id => @order.id, :comment => @comment
    @order = assigns(:order)
    response.redirect_url.should == 'http://www.example.com/backend/acknowledge'
  end
  
  
  When "he deletes order" do
    post "/backend/acknowledge/destroy/#{@order.id}"
    @order = assigns(:order)
    response.redirect_url.should == 'http://www.example.com/backend/acknowledge'
  end
  
###############################################

  
end
