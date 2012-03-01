class Backend::AcknowledgeController < Backend::BackendController

  before_filter do
    begin
      @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
      @order = @user.orders.submitted.scoped_by_inventory_pool_id(current_inventory_pool).find(params[:id]) if params[:id] and @user
    rescue
      respond_to do |format|
        format.html { redirect_to :action => 'index' unless @order }
        format.js { render :text => _("User or Order not found"), :status => 500 }
      end
    end
  end
  
######################################################################
 
  def index
=begin    
    with = { :inventory_pool_id => current_inventory_pool.id }
    with[:user_id] = @user.id if @user

    @orders = Order.sphinx_submitted.search params[:query], { :star => true, :page => params[:page], :per_page => $per_page,
                                                              :with => with }

    respond_to do |format|
      format.html
      format.js { search_result_rjs(@orders) }
    end
=end
  end
  
  def show
    # OLD ? @source_path = request.env['REQUEST_URI']
    add_visitor(@order.user)
    
    @order_json = order_json_response
  end
  
  def approve(force = (params.has_key? :force) ? true : false)
    #old# if request.post?
    if @order.approve(params[:comment], true, current_user, force)
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
      @order.save
      Notification.order_rejected(@order, params[:comment], true, current_user )
      
      respond_to do |format|
        format.js { render :json => true, :status => 200 }
      end
    else
      errors = @order.errors.full_messages.join("\n")
      respond_to do |format|
        format.js { render :text => errors, :status => 500 }
      end
    end
  end 

  def delete
      params[:layout] = "modal"
  end
  
  def destroy
      @order.destroy
      redirect_to :controller=> 'acknowledge', :action => 'index'
  end

###################################################################################
# old code #

=begin
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

  def remove_lines
    generic_remove_lines(@order)
  end

  def add_line
    generic_add_line(@order)
  end
=end

  def time_lines
    generic_time_lines(@order)
  end    
  
###################################################################################
# new code #

  def add_line( quantity = params[:quantity],
                start_date = params[:start_date],
                end_date = params[:end_date],
                model_id = params[:model_id],
                model_group_id = params[:model_group_id] )
    
    model = if model_group_id
      ModelGroup.find(model_group_id) # TODO scope current_inventory_pool ?
    elsif model_id
      current_inventory_pool.models.find(model_id)
    else
      raise "either model_id or model_group_id required"
    end
    
    model.add_to_document(@order, current_user.id, quantity, start_date, end_date, current_inventory_pool)

    flash[:notice] = @order.errors.full_messages unless @order.save
    order_respond_to
  end

  def update_lines(line_ids = params[:line_ids] || [],
                   line_id_model_id = params[:line_id_model_id] || {},
                   quantity = params[:quantity],
                   start_date = params[:start_date],
                   end_date = params[:end_date],
                   delete_line_ids = params[:delete_line_ids] || [])

    OrderLine.transaction do
      unless delete_line_ids.blank?
        to_delete_lines = @order.lines.find(delete_line_ids)
        to_delete_lines.each do |line|
          change = _("Deleted %s (%s - %s)") % [line.model, line.start_date, line.end_date]
          @order.log_change(change, current_user.id)
        end
        OrderLine.delete(to_delete_lines.map(&:id))
      end

      order_lines = @order.lines.find(line_ids - delete_line_ids)
      # TODO merge to Order#update_line
      order_lines.each do |order_line|
        order_line.quantity = [quantity.to_i, 0].max if quantity
        order_line.start_date = Date.parse(start_date) if start_date
        order_line.end_date = Date.parse(end_date) if end_date
        order_line.model = order_line.order.user.models.find(new_model_id) if (new_model_id = line_id_model_id[order_line.id.to_s]) 
        
        change = _("[Model %s] ") % order_line.model 
        change += order_line.changes.map do |c|
          what = c.first
          if what == "model_id"
            from = Model.find(from).to_s
            _("Swapped from %s ") % [from]
          else
            from = c.last.first
            to = c.last.last
            _("Changed %s from %s to %s") % [what, from, to]
          end
        end.join(', ')

        @order.log_change(change, current_user.id) if order_line.save
      end
    end
    
    
    respond_to do |format|
      format.js { render :json => order_json_response, :status => 200 }
    end
  end

  def order_json_response
    @order.to_json(:with => {:lines => {:include => {:model => {}, 
                                                     :order => {:include => {:user => {:include => :groups}}}},
                                        :with => {:availability => {:inventory_pool => current_inventory_pool}},
                                        :methods => :is_available },
                             :user => {}},
                   :methods => :quantity,
                   :include => {:user => {:include => [:groups]}}
                   )
  end

###################################################################################
  
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
    
end
