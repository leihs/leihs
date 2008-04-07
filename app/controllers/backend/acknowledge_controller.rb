class Backend::AcknowledgeController < Backend::BackendController

  def index
  end
  
  def show
    @order = Order.find(params[:id])
  end
  
  def approve
    if request.post?
      @order = Order.find(params[:id])
      @order.status = Order::APPROVED
      @order.save
      if @order.has_changes?
        OrderMailer.deliver_changed(@order, params[:comment])
      else
        OrderMailer.deliver_approved(@order, params[:comment])
      end

      # TODO rjs: close the modal and responde to the parent window
      init
      redirect_to :action => 'index'
    else
      render :layout => 'backend/00-patterns/modal'
    end
    
  end
  
  def reject
    if request.post?
      @order = Order.find(params[:id])
      @order.status = Order::REJECTED
      @order.save
      OrderMailer.deliver_rejected(@order, params[:comment])
      
      # TODO rjs: close the modal and responde to the parent window
      init
      redirect_to :action => 'index'
    else
      render :layout => 'backend/00-patterns/modal'
    end
  end 
  
  
  def change_line
    if request.post?
      @order_line = OrderLine.find(params[:id])
      @order = @order_line.order
      required_quantity = params[:quantity].to_i
      @order_line, @change = @order.update_line(@order_line.id, required_quantity, session[:user_id])
      @order.save
    end
  end
  
  def add_line
    if request.post?
      @order = Order.find(params[:id])
      @order.add_line(params[:quantity].to_i, Model.find(params[:model_id]), params[:user_id])
      if not @order.save
        flash[:notice] = _("Model couldn't be added")
      end
    end
  rescue
    puts $!
  end
  

end
