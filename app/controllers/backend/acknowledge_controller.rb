class Backend::AcknowledgeController < Backend::BackendController

  before_filter do
    begin
      @contract = current_inventory_pool.contracts.submitted.find(params[:id]) if params[:id]
    rescue
      respond_to do |format|
        format.html { redirect_to :action => 'index' unless @contract } # FIXME
        format.json { render :text => _("User or Order not found"), :status => 500 }
      end
    end
  end
  
######################################################################
 
  def show
    add_visitor(@contract.user)
  end
  
  def approve(force = (params.has_key? :force) ? true : false)
    if @contract.approve(params[:comment], true, current_user, force)
      respond_to do |format|
        format.json { render :json => true, :status => 200  }
      end
    else
      errors = @contract.errors.full_messages.uniq.join("\n")
      respond_to do |format|
        format.json { render :text => errors, :status => 500 }
      end
    end
  end
  
  def reject
    if request.post? and params[:comment]
      @contract.update_attributes(status: :rejected)
      Notification.order_rejected(@contract, params[:comment], true, current_user )
      
      respond_to do |format|
        format.json { render :json => true, :status => 200 }
      end
    else
      errors = @contract.errors.full_messages.uniq.join("\n")
      respond_to do |format|
        format.json { render :text => errors, :status => 500 }
      end
    end
  end 

  def delete
      params[:layout] = "modal" #old??#
  end
  
  def destroy
      @contract.destroy
      redirect_to :controller=> 'acknowledge', :action => 'index'
  end

###################################################################################

  def add_line( quantity = (params[:quantity] || 1).to_i,
                start_date = (params[:start_date].try{|x| Date.parse(x)} || Date.today rescue Date.today),
                end_date = (params[:end_date].try{|x| Date.parse(x)} || Date.tomorrow rescue Date.tomorrow),
                model_id = params[:model_id],
                model_group_id = params[:model_group_id],
                code = params[:code])
                
    # find model 
    model = if not code.blank?
      item = current_inventory_pool.items.where(:inventory_code => code).first 
      item.model if item
    elsif model_group_id
      Template.find(model_group_id) # TODO scope current_inventory_pool ?
    elsif model_id
      current_inventory_pool.models.find(model_id)
    end
    
    # create new line
    if model
      lines = model.add_to_contract(@contract, @user, quantity, start_date, end_date)
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
          render :json => view_context.json_for(lines, {:preset => :order_line})
        else
          render :json => view_context.error_json(@error), status: 500
        end
      } 
    end
  end
  
###################################################################################

  def remove_lines(line_ids = params[:line_ids] || raise("line_ids is required"))
    respond_to do |format|
      format.json {
        begin
          ContractLine.transaction do
            unless line_ids.all? {|l| @contract.remove_line(l, current_user.id)}
              raise _("You cannot delete all lines of an order. Perhaps you want to reject it instead?")
            end
          end
          render :json => {}
        rescue => e
          render :json => view_context.error_json({:message => e.to_s}),
                 :status => 500
        end
      }
    end
  end

  ###################################################################################

  def update_lines(line_ids = params[:line_ids] || raise("line_ids is required"),
                   line_id_model_id = params[:line_id_model_id] || {},
                   quantity = (params[:quantity] ? [params[:quantity].to_i, 1].max : nil),
                   start_date = params[:start_date],
                   end_date = params[:end_date])

    if quantity
      if quantity.to_i > line_ids.size # if quantity is higher then line ids then duplicate lines
        (quantity.to_i-line_ids.size).times do
          new_line = ContractLine.find(line_ids.first).dup # NOTE use .dup instead of .clone (from Rails 3.1)
          new_line.save # TODO log_change (not needed anymore with the new audits) 
          line_ids.push new_line.id
        end
      elsif quantity.to_i < line_ids.size # if quantity is lower then line ids then remove some lines
        (line_ids.size-quantity.to_i).times do
          line_to_be_removed = ContractLine.find(line_ids.pop)
          ContractLine.transaction do
            @contract.remove_line(line_to_be_removed, current_user.id)
          end
        end
      end
    end
    
    @contract.update_lines(line_ids, line_id_model_id, start_date, end_date, current_user.id)

    respond_to do |format|
      format.json {
        render :json => view_context.json_for(@contract.reload, {:preset => :order})
      }
    end
  end

###################################################################################

  def change_purpose(purpose_description = params[:purpose])
    @contract.change_purpose(purpose_description, current_user.id)
    render :json => {:purpose => @contract.purpose.to_s}
  end
    
  def swap_user
    if params[:swap_user_id].nil?
      flash[:notice] = _("User must be selected")
    else
      new_user = User.find(params[:swap_user_id])
      if (new_user.id != @contract.user_id)
        change = _("User swapped %{from} for %{to}") % { :from => @contract.user.login, :to => new_user.login}
        @contract.user = new_user
        @contract.log_change(change, current_user.id)
        @contract.save
      end
    end  
    respond_to do |format|
      format.json {
        render :json => view_context.json_for(@contract, {:preset => :order})
      }
    end
  end   
    
end
