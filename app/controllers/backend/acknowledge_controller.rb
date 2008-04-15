class Backend::AcknowledgeController < Backend::BackendController

  def index
  end
  
  def show
    @order = Order.find(params[:id])
  end
  
  def approve
    if request.post?
      @order = Order.find(params[:id])
      @order.status_const = Order::APPROVED
      @order.save
      if @order.has_changes?
        OrderMailer.deliver_changed(@order, params[:comment])
      else
        OrderMailer.deliver_approved(@order, params[:comment])
      end

      init
      redirect_to :action => 'index'
    else
      render :layout => $modal_layout_path
    end
    
  end
  
  def reject
    if request.post?
      @order = Order.find(params[:id])
      @order.status_const = Order::REJECTED
      @order.save
      OrderMailer.deliver_rejected(@order, params[:comment])
      
      init
      redirect_to :action => 'index'
    else
      render :layout => $modal_layout_path
    end
  end 
  
  def swap_line
    if request.post?
      @order = Order.find(params[:id])
      if params[:model_id].nil?
        flash[:notice] = _("Model must be selected")
      else
        @order.swap_line(params[:order_line_id], params[:model_id], session[:user_id])
      end  
      redirect_to :controller=> 'acknowledge', :action => 'show', :id => @order.id        
    else
      redirect_to :controller => 'search', :action => 'model', :id => params[:id], :order_line_id => params[:order_line_id]
    end
  end
  
  def change_line
    if request.post?
      @order_line = OrderLine.find(params[:order_line_id])
      @order = @order_line.order
      required_quantity = params[:quantity].to_i
      @order_line, @change = @order.update_line(@order_line.id, required_quantity, session[:user_id])
      @maximum_exceeded = required_quantity != @order_line.quantity
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
  end

  
  def remove_lines
     if request.post?
        @order = Order.find(params[:id])
        params[:order_lines].each {|ol| @order.remove_line(ol, session[:user_id]) }
        redirect_to :controller=> 'acknowledge', :action => 'show', :id => @order.id
    else
      @order_lines = OrderLine.find(params[:order_lines].split(','))
      render :layout => $modal_layout_path
    end   
  end  
  
end
