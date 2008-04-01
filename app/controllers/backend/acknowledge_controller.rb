class Backend::AcknowledgeController < Backend::BackendController


  def create_some_inventory
    params[:id].to_i.times do |i|
      m = Model.new(:name => params[:name] + " " + i.to_s)
      m.save
      5.times do |serial_nr|
        i = Item.new(:model_id => m.id, :inventory_code => serial_nr)
        
        i.save        
      end
    end
  end
  
  def create_some_users
    params[:id].to_i.times do |i|
      u = User.new(:login => "#{params[:name]}_#{i}")
      u.save
    end
  end
  
  def create_some_new_orders
    users = User.find(:all)
    models = Model.find(:all)
    params[:id].to_i.times do |i|
      order = Order.new()
      order.user_id = users[rand(users.size)].id
      order.add(rand(3), models[rand(models.size)])
      order.save
    end
  end
  
  def index
  end
  
  def show
    @order = Order.find(params[:id])
  end
  
  def approve
    @order = Order.find(params[:id])
    @order.status = Order::APPROVED
    @order.save
    OrderMailer.deliver_approved(@order)
    init
    redirect_to :controller=> 'acknowledge', :action => 'index'
  end
  
  def reject
    @order = Order.find(params[:id])
    if request.post?
      @order.status = Order::REJECTED
      @order.save
      OrderMailer.deliver_rejected(@order, params[:reason])
      init
      redirect_to :controller => 'acknowledge', :action => 'index'
    end
  end 
  
  
  def change_line
    if request.post?
      @order_line = OrderLine.find(params[:id])
      original = @order_line.quantity
      required_quantity = params[:quantity].to_i
      @order_line.quantity = required_quantity < max_available ? required_quantity : max_available
      @change = "Quantity updated from #{original.to_s} to #{@order_line.quantity}"
      
      if required_quantity > max_available
        @flash_notice = _("Maximum number of items available at that time is 9")
        @change += " (maximum available)"
      end
      
      @order_line.save
    end
  end
  
  private
  
  def max_available
    10
  end
end
