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
  
end
