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
    OrderMailer.deliver_approved(@order, params[:comment])
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
      @change = "Changed quantity for #{@order_line.model.name} from #{original.to_s} to #{@order_line.quantity}" #TODO: Translation required
      
      if required_quantity > max_available
        @flash_notice = _("Maximum number of items available at that time is") + " " + max_available
        @change += _(" (maximum available)")
      end
      
      @order_line.save
    end
  end
  
  def add_line
    if request.post?
      @order = Order.find(params[:id])
      @order.add(params[:quantity].to_i, params[:model_id])
      if not @order.save
        flash[:notice] = _("Model couldn't be added")
      end
    end
  end
  
  
  private
  
  def max_available
    10 #TODO: When we have reservations and stuff
  end
end
