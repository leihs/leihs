steps_for(:order) do
 
  
  Given "the list of submitted orders contains $total elements" do | total |
    orders = Order.submitted
    orders.size.should == 0
    user = Factory.create_user
    total.to_i.times { orders << Factory.create_order(:user_id => user.id).submit }
    orders.size.should == total.to_i
  end

  When "$who chooses one order" do | who |
    order = @orders.first
    get backend_inventory_pool_user_acknowledge_path(@inventory_pool, order.user, order)
    response.should render_template('backend/acknowledge/show')
    @order = assigns(:order)
  end

###############################################

  When "$who approves order" do |who|
    @comment ||= ""
    @order.approvable?.should be_true
    post approve_backend_inventory_pool_user_acknowledge_path(@inventory_pool, @order.user, @order, :comment => @comment)
    @order = assigns(:order)
    @order.should_not be_nil
    @order.approvable?.should be_false
    @orders_size = assigns(:to_acknowledge_size)
    response.redirect_url.should == "http://www.example.com/backend/inventory_pools/#{@inventory_pool.id}/acknowledge"
    @response = response
  end


  When "$who rejects order" do |who|
    @comment ||= ""
    post reject_backend_inventory_pool_user_acknowledge_path(@inventory_pool, @order.user, @order, :comment => @comment)
    @order = assigns(:order)
    response.redirect_url.should == "http://www.example.com/backend/inventory_pools/#{@inventory_pool.id}/acknowledge"
  end
  
  
  When "he deletes order" do
    delete backend_inventory_pool_user_acknowledge_path(@inventory_pool, @order.user, @order)
    @order = assigns(:order)
    response.redirect_url.should == "http://www.example.com/backend/inventory_pools/#{@inventory_pool.id}/acknowledge"
  end
  
###############################################

  
end
