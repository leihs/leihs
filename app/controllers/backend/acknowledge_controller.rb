class Backend::AcknowledgeController < Backend::BackendController

  before_filter do
    begin
      @order = current_inventory_pool.orders.submitted.find(params[:id]) if params[:id]
    rescue
      respond_to do |format|
        format.html { redirect_to :action => 'index' unless @order }
        format.json { render :text => _("User or Order not found"), :status => 500 }
      end
    end
  end
  
######################################################################
 
  def show
    # OLD ? @source_path = request.env['REQUEST_URI']
    add_visitor(@order.user)
  end
  
  def approve(force = (params.has_key? :force) ? true : false)
    #old# if request.post?
    if @order.approve(params[:comment], true, current_user, force)
      # TODO test# @order.destroy # TODO remove old orders ?
      respond_to do |format|
        #old# format.html { redirect_to :action => 'index' }
        format.json { render :json => true, :status => 200  }
      end
    else
      errors = @order.errors.full_messages.join("\n")
      #old# flash[:error] = errors if @order.errors.size > 0
      respond_to do |format|
        #old# format.html { params[:layout] = "modal" }
        format.json { render :text => errors, :status => 500 }
      end
    end
  end
  
  def reject
    if request.post? and params[:comment]
      @order.status_const = Order::REJECTED
      @order.save
      Notification.order_rejected(@order, params[:comment], true, current_user )
      
      respond_to do |format|
        format.json { render :json => true, :status => 200 }
      end
    else
      errors = @order.errors.full_messages.join("\n")
      respond_to do |format|
        format.json { render :text => errors, :status => 500 }
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
=end

###################################################################################

  def add_line( quantity = (params[:quantity] || 1).to_i,
                start_date = params[:start_date].try{|x| Date.parse(x)} || Date.today,
                end_date = params[:end_date].try{|x| Date.parse(x)} || Date.tomorrow,
                model_id = params[:model_id],
                model_group_id = params[:model_group_id],
                code = params[:code])
                
     # find model 
    model = if not code.blank?
      item = current_inventory_pool.items.where(:inventory_code => code).first 
      item.model if item
    elsif model_group_id
      ModelGroup.find(model_group_id) # TODO scope current_inventory_pool ?
    elsif model_id
      current_inventory_pool.models.find(model_id)
    end
    
    # create new line
    if model
      line = model.add_to_document(@order, @user, quantity, start_date, end_date, current_inventory_pool)
    else
      @error = if code
        {:message => _("A model for the Inventory Code / Serial Number '%s' was not found" % code)}
      elsif model_id
        {:message => _("A model with the ID '%s' was not found" % model_id)}
      elsif model_group_id
        {:message => _("A template with the ID '%s' was not found" % model_group_id)}
      end
    end
    
    respond_to do |format|
      format.json {
        if @error.blank?
          with = {:model => {},
                  :order => {},
                  :user => {}, 
                  :is_available => true, 
                  :availability_for_inventory_pool => true, 
                  :inventory_pool_id => true,
                  :quantity => true,
                  :dates => true,
                  :quantity => true,
                  :purpose => true}
          render :json => view_context.json_for(Array(line), with)
        else
          render :json => view_context.error_json(@error), status: 500
        end
      } 
    end
  end
  
###################################################################################

  def update_lines(line_ids = params[:line_ids] || raise("line_ids is required"),
                   line_id_model_id = params[:line_id_model_id] || {},
                   quantity = params[:quantity],
                   start_date = params[:start_date],
                   end_date = params[:end_date],
                   delete_line_ids = params[:delete_line_ids] || [])
    
    OrderLine.transaction do
      unless delete_line_ids.blank?
        delete_line_ids.each {|l| @order.remove_line(l, current_user.id)}
      end

      lines = @order.lines.find(line_ids - delete_line_ids)
      # TODO merge to Order#update_line
      lines.each do |line|
        line.quantity = [quantity.to_i, 1].max if quantity
        line.start_date = Date.parse(start_date) if start_date
        line.end_date = Date.parse(end_date) if end_date
        # log changes
        change = ""
        if (new_model_id = line_id_model_id[line.id.to_s]) 
          line.model = line.order.user.models.find(new_model_id) 
          change = _("[Model %s] ") % line.model 
        end
        change += line.changes.map do |c|
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

        @order.log_change(change, current_user.id) if line.save
      end
    end
    
    respond_to do |format|
      format.json {
        with = { :lines => {:model => {},
                            :order => {:user => {:groups => true}}, # FIXME remove this, we already have it as parent
                            :availability_for_inventory_pool => true,
                            :dates => true,
                            :quantity => true,
                            :is_available => true},
                 :user => {:groups => true},
                 :quantity => true,
                 :purpose => true }
        render :json => view_context.json_for(@order, with)
      }
    end
  end

###################################################################################

  def change_purpose(purpose_description = params[:purpose])
    @order.change_purpose(purpose_description, current_user.id)
    render :json => {:purpose => @order.purpose.to_s}
  end
    
  def swap_user
    if request.post?
      if params[:swap_user_id].nil?
        flash[:notice] = _("User must be selected")
      else
        @order.swap_user(params[:swap_user_id], current_user.id)
      end  
      redirect_to backend_inventory_pool_acknowledge_path(current_inventory_pool, @order)
    else
      redirect_to backend_inventory_pool_users_path(current_inventory_pool,
                                                    :layout => 'modal',
                                                    :source_path => request.env['REQUEST_URI'])
    end
  end   
    
end
