class Backend::AcknowledgeController < Backend::BackendController

  before_filter :pre_load

  def index
    with = { :inventory_pool_id => current_inventory_pool.id }
    with[:user_id] = @user.id if @user

    @orders = Order.sphinx_submitted.search params[:query], { :star => true, :page => params[:page], :per_page => $per_page,
                                                              :with => with }

    @working_orders = Order.sphinx_submitted.search params[:query], { :star => true, :page => params[:page], :per_page => $per_page,
                                                                      :without => {:backup_id => 0},
                                                                      :with => with }
    respond_to do |format|
      format.html
      format.js { search_result_rjs(@orders) }
    end
  end
  
  def show
    @source_path = request.env['REQUEST_URI']
    @order.to_backup unless @order.has_backup?
    add_visitor(@order.user)
    
    @grouped_lines = @order.lines.group_by {|x| [x.start_date.to_formatted_s(:db), x.end_date.to_formatted_s(:db)] }.map{|k,v| {k=>v}}
  end
  
  def approve
    if request.post? and @order.approve(params[:comment], current_user)
      # TODO test# @order.destroy # TODO remove old orders ?
      
      respond_to do |format|
        #old# format.html { redirect_to :action => 'index' }
        format.js { render :json => true, :status => 200  }
      end
    else
      errors = @order.errors.full_messages.join("\n")
      #old# flash[:error] = errors if @order.errors.size > 0
      respond_to do |format|
        #old# format.html { params[:layout] = "modal" }
        format.js { render :text => errors, :status => 500 }
      end
    end
  end
  
  def reject
    if request.post? and params[:comment]
      @order.status_const = Order::REJECTED
      @order.backup = nil
      @order.save
      Notification.order_rejected(@order, params[:comment], true, current_user )
      
      respond_to do |format|
        #old# redirect_to :action => 'index'
        format.js { render :json => true, :status => 200 }
      end
    else
      respond_to do |format|
        #old# params[:layout] = "modal"
        format.js { render :text => errors, :status => 500 }
      end
    end
  end 

  def restore
    if request.post?
      @order.from_backup      
      redirect_to :action => 'index'        
    else
      params[:layout] = "modal"
    end
  end 
  
  def delete
      params[:layout] = "modal"
  end
  
  def destroy
      @order.destroy
      redirect_to :controller=> 'acknowledge', :action => 'index'
  end

  def add_line
    generic_add_line(@order)
  end

  def swap_model_line
    generic_swap_model_line(@order)
  end
  
  # change quantity for a given line
  def change_line_quantity
    @order_line = current_inventory_pool.order_lines.find(params[:order_line_id])
    @order = @order_line.order
    required_quantity = params[:quantity].to_i

    @order_line, @change = @order.update_line(@order_line.id, required_quantity, current_user.id)
    @order.save
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
      redirect_to backend_inventory_pool_user_acknowledge_path(current_inventory_pool, @order.user, @order)
    else
      params[:layout] = "modal"
    end
  end
    
   def swap_user
    if request.post?
      if params[:swap_user_id].nil?
        flash[:notice] = _("User must be selected")
      else
        @order.swap_user(params[:swap_user_id], current_user.id)
      end  
      redirect_to backend_inventory_pool_user_acknowledge_path(current_inventory_pool, @order.user, @order)
    else
      redirect_to backend_inventory_pool_users_path(current_inventory_pool,
                                                    :layout => 'modal',
                                                    :source_path => request.env['REQUEST_URI'])
    end
  end   
    
  private
  
  def pre_load
      @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
      @order = @user.orders.submitted.find(params[:id]) if params[:id] and @user
    rescue
      respond_to do |format|
        format.html { redirect_to :action => 'index' unless @order }
        format.js { render :text => _("User or Order not found"), :status => 500 }
      end
  end
    
end
