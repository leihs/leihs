class OrdersController < Frontend1Controller

  before_filter :pre_load, :except => [:index, :new]

  def index
    @orders = current_user.orders
  end
  
  def new
    @order = current_user.get_current_order
    render :layout => false if params[:_dc] # TODO temp extjs
  end

  def submit
    @order.created_at = DateTime.now
    if request.post? and @order.submit(params[:purpose])
      
      redirect_to '/'
    else
      render :layout => $modal_layout_path
    end        
  end

  # TODO merge reservation and acknowledge methods? (i.e. mixin module)
  def add_line
    if request.post?
      @order = current_user.get_current_order unless @order

      if params[:model_group_id]
        model = ModelGroup.find(params[:model_group_id])
      else
        model = Model.find(params[:model_id])
      end
      # TODO params[:user_id] ||= current_user.id
      model.add_to_document(@order, params[:user_id], params[:quantity])
      
      flash[:notice] = _("Line couldn't be added") unless @order.save
      if request.xml_http_request?
        render :partial => 'basket'      
      else
        redirect_to :action => 'new', :id => @order.id        
      end
    else
      redirect_to :controller => 'models',
                  :action => 'search',
                  :id => params[:id],
                  :source_controller => params[:controller],
                  :source_action => params[:action]
    end
  end

  # TODO merge reservation and acknowledge methods? (i.e. mixin module)
  # change quantity for a given line
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

########################################################
  

  private
  
  def pre_load
      @order = Order.find(params[:id], :conditions => { :status_const => Order::NEW }) if params[:id]
    rescue
      redirect_to :action => 'index' unless @order
  end  
end
