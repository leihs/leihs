class Backend::AcknowledgeController < Backend::BackendController

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
      @order_line.quantity = params[:quantity].to_i
      @success = @order_line.save
    end
  end
  
end
