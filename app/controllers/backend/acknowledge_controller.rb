class Backend::AcknowledgeController < Backend::BackendController

  before_filter :pre_load

  def index
    orders = current_inventory_pool.orders.submitted
    @submitted_orders = orders
    @working_orders = orders.select { |o| o.has_backup? }

    orders = orders & @user.orders.submitted if @user

    @orders = orders.search(params[:query], :page => params[:page], :per_page => $per_page)
  end
  
  def show
    @order.to_backup unless @order.has_backup?
    set_order_to_session(@order)
  end
  
  def approve
    if request.post? and @order.approve(params[:comment])
      # TODO test# @order.destroy # TODO remove old orders ?
      remove_order_from_session
      redirect_to :action => 'index'
    else
      render :layout => $modal_layout_path
    end    
  end
  
  def reject
    if request.post? and params[:comment]
      @order.status_const = Order::REJECTED
      @order.backup = nil
      @order.save
      Notification.order_rejected(@order, params[:comment] )
      
      remove_order_from_session
      redirect_to :action => 'index'
    else
      render :layout => $modal_layout_path
    end
  end 

  def restore
    if request.post?
      @order.from_backup      
      redirect_to :action => 'index'        
    else
      render :layout => $modal_layout_path
    end
  end 
  
  def delete
      render :layout => $modal_layout_path
  end
  
  def destroy
      @order.destroy
      remove_order_from_session
      redirect_to :controller=> 'acknowledge', :action => 'index'
  end

  def add_line
    generic_add_line(@order)
  end

  def swap_model_line
    generic_swap_model_line(@order)
  end
  
  # change quantity for a given line
  def change_line
    if request.post?
      @order_line = current_inventory_pool.order_lines.find(params[:order_line_id])
      @order = @order_line.order
      required_quantity = params[:quantity].to_i

      @order_line, @change = @order.update_line(@order_line.id, required_quantity, current_user.id)
      @maximum_exceeded = required_quantity != @order_line.quantity
      @order.save
    end
  end

  def time_lines
    generic_time_lines(@order)
  end    
  
  def remove_lines
    generic_remove_lines(@order)
  end

  def change_purpose
    if request.post?
      @order.change_purpose(params[:purpose], current_user.id)
      redirect_to backend_inventory_pool_user_acknowledge_path(@current_inventory_pool, @order.user, @order)
    else
      render :layout => $modal_layout_path
    end
  end
    
   def swap_user
    if request.post?
      if params[:swap_user_id].nil?
        flash[:notice] = _("User must be selected")
      else
        @order.swap_user(params[:swap_user_id], current_user.id)
      end  
      redirect_to backend_inventory_pool_user_acknowledge_path(@current_inventory_pool, @order.user, @order)
    else
      redirect_to :controller => 'users', 
                  :layout => 'modal',
                  :source_path => request.env['REQUEST_URI']
    end
  end   

  def timeline
    @timeline_xml = @order.timeline
    render :nothing => true, :layout => 'backend/' + $theme + '/modal_timeline'
  end
    
    
  private
  
  def pre_load
      @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
      @order = @user.orders.submitted.find(params[:id]) if params[:id] and @user
    rescue
      redirect_to :action => 'index' unless @order
  end
    
end
