class Backend::AcknowledgeController < Backend::BackendController

  before_filter :load_order, :except => :index

  def index
    @submitted_orders = current_inventory_pool.orders.submitted_orders
    @working_orders = @submitted_orders.select { |o| o.has_backup? }

    if params[:search]
      params[:search] = "*#{params[:search]}*" # search with partial string
      @orders = @submitted_orders.find_by_contents(params[:search])
    elsif params[:user_id]
      # OPTIMIZE named_scope intersection?
      @user = User.find(params[:user_id])
      @orders = @submitted_orders & @user.orders.submitted_orders
    end
    
    render :partial => 'orders' if request.post?
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
      OrderMailer.deliver_rejected(@order, params[:comment])
      
      remove_order_from_session
      redirect_to :action => 'index'
    else
      render :layout => $modal_layout_path
    end
  end 

  def restore
    if request.post?
      @order.from_backup      
      redirect_to :controller=> 'acknowledge', :action => 'index'        
    else
      render :layout => $modal_layout_path
    end
  end 
  
  def destroy
     if request.post?
        @order.destroy
        remove_order_from_session
        redirect_to :controller=> 'acknowledge', :action => 'index'
    else
      render :layout => $modal_layout_path
    end    
  end

  def add_line
    generic_add_line(@order, @order.id)
  end

  def swap_model_line
    generic_swap_model_line(@order, @order.id)
  end
  
  # change quantity for a given line
  def change_line
    if request.post?
      @order_line = current_inventory_pool.order_lines.find(params[:order_line_id])
      @order = @order_line.order
      required_quantity = params[:quantity].to_i

      @order_line, @change = @order.update_line(@order_line.id, required_quantity, session[:user_id])
      @maximum_exceeded = required_quantity != @order_line.quantity
      @order.save
    end
  end

  # change quantity for a given line group
  def change_line_group
    if request.post?
      @line_group = @order.line_groups.find(params[:line_group_id])
      required_quantity = params[:quantity].to_i
      
      # prevent division by zero
      if required_quantity > 0 and @line_group.quantity > 0
        @line_group.lines.each do |l|
          params[:quantity] = l.quantity * required_quantity / @line_group.quantity
          params[:order_line_id] = l.id
          change_line
        end
        
        @line_group.quantity = required_quantity
        @line_group.save
      end

      render :partial => 'lines'
    end
  end

  def time_lines
    generic_time_lines(@order, @order.id)
  end    
  
  def remove_lines
    generic_remove_lines(@order, @order.id)
  end

  def add_options
    @option = params[:option_id].nil? ? Option.new : Option.find(params[:option_id]) # TODO scope current_inventory_pool
    if request.post?
      params[:lines].each do | ol | 
        line = current_inventory_pool.order_lines.find(ol)
        option = Option.new(params[:option])
        if option.save
          line.options << option
          line.save
          @order.log_change(_("Added Option:") + " (#{option.quantity}) #{option.name}", session[:user_id])
        else
          flash[:notice] = _("Couldn't create option.")
        end
      end
      redirect_to :controller=> 'acknowledge', :action => 'show', :id => @order.id      
    else
      @order_lines = current_inventory_pool.order_lines.find(params[:lines].split(','))
      render :layout => $modal_layout_path      
    end
  end

  def remove_options
     if request.post?
        params[:options].each {|o| @order.remove_option(o, session[:user_id]) }
        redirect_to :controller=> 'acknowledge', :action => 'show', :id => @order.id
    else
      @options = Option.find(params[:options].split(',')) # TODO scope current_inventory_pool
      render :layout => $modal_layout_path
    end   
  end


  def change_purpose
    if request.post?
      @order.change_purpose(params[:purpose], session[:user_id])
      redirect_to :controller=> 'acknowledge', :action => 'show', :id => @order.id
    else
      render :layout => $modal_layout_path
    end
  end
    
   def swap_user
    if request.post?
      if params[:user_id].nil?
        flash[:notice] = _("User must be selected")
      else
        @order.swap_user(params[:user_id], session[:user_id])
      end  
      redirect_to :controller=> 'acknowledge', :action => 'show', :id => @order.id        
    else
      redirect_to :controller => 'users', 
                  :action => 'search',
                  :id => params[:id],
                  :source_controller => 'acknowledge',
                  :source_action => 'swap_user'
    end
  end   

  def timeline
    @timeline_xml = @order.timeline
    render :text => "", :layout => 'backend/' + $theme + '/modal_timeline'
  end
    
    
  private
  
  def load_order
      @order = current_inventory_pool.orders.submitted_orders.find(params[:id]) if params[:id]
    rescue
      redirect_to :action => 'index' unless @order
  end
    
end
