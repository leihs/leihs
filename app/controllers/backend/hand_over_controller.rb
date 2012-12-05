class Backend::HandOverController < Backend::BackendController
  
  before_filter do
    @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
    @contract = @user.get_current_contract(current_inventory_pool) if @user
  end

######################################################################

  def show
    #OLD? @missing_fields = @user.authentication_system.missing_required_fields(@user)
    @visits = @user.visits.hand_over.scoped_by_inventory_pool_id(current_inventory_pool)
    add_visitor(@user)
  end
  
  def delete_visit(visit = @user.visits.hand_over.find(params[:visit_id]) || raise("visit_id is required"))
    respond_to do |format|
      format.json {
        if @contract.remove_lines(visit.lines, current_user.id)
          render :json => true, :status => 200
        else
          render :json => false, :status => 500
        end
      }
    end
  end
  
  # Sign definitely the contract
  def sign_contract(line_ids = params[:line_ids] || raise("line_ids is required"),
                    purpose_description = (params[:purpose].empty?) ? nil : params[:purpose],
                    note = params[:note])
    
    lines = @contract.contract_lines.find(line_ids)
    @contract.note = note if note
    if purpose_description
      purpose = Purpose.create :description => purpose_description
      lines.each do |line|
        if line.purpose.nil?
          line.purpose = purpose
          line.save
        end
      end
    end

    respond_to do |format|
      format.json {
        if @contract.sign(current_user, lines)
          render :json => view_context.json_for(@contract.reload, {:preset => :contract})
        else
          @error = {:message => @contract.errors.full_messages}
          render :json => view_context.error_json(@error), status: 500
        end
      }
    end
  end

  def update_lines(line_ids = params[:line_ids] || raise("line_ids is required"),
                   line_id_model_id = params[:line_id_model_id] || {},
                   quantity = (params[:quantity] ? [params[:quantity].to_i, 1].max : nil),
                   start_date = params[:start_date],
                   end_date = params[:end_date])

    if quantity
      if quantity.to_i > line_ids.size # if quantity is higher then line ids then duplicate lines
        if ContractLine.find(line_ids.first).is_a?(ItemLine)
          (quantity.to_i-line_ids.size).times do
            new_line = ItemLine.find(line_ids.first).dup # NOTE use .dup instead of .clone (from Rails 3.1) 
            new_line.item = nil
            new_line.save # TODO log_change (not needed anymore with the new audits) 
            line_ids.push new_line.id
          end
        else # Option
          OptionLine.find(line_ids.first).update_attribute :quantity, quantity
        end
      elsif quantity.to_i < line_ids.size # if quantity is lower then line ids then remove some lines
        if ContractLine.find(line_ids.first).is_a?(ItemLine)
          (line_ids.size-quantity.to_i).times do
            line_to_be_removed = ContractLine.find(line_ids.pop)
            ContractLine.transaction do
              @contract.remove_line(line_to_be_removed, current_user.id)
            end
          end
        else # Option
          OptionLine.find(line_ids.first).update_attribute :quantity, quantity
        end
      end
    end

    @contract.update_lines(line_ids, line_id_model_id, start_date, end_date, current_user.id)

    respond_to do |format|
      format.json {
        # TODO: RETURN ONLY UPDATED LINES
        visits = @user.visits.hand_over.scoped_by_inventory_pool_id(current_inventory_pool)
        render :json => view_context.json_for(visits, {:preset => :hand_over_visit})
      }
    end
  end
  
###################################################################################
  
  def remove_lines(line_ids = params[:line_ids] || raise("line_ids is required"))
    line_ids.each {|l| @contract.remove_line(l, current_user.id)}
    
    respond_to do |format|
      format.json { render :json => {} }
    end
  end
  
###################################################################################


  # given an inventory_code, searches for a matching contract_line
  # and if not found, adds an option
  def assign_inventory_code(inventory_code = params[:inventory_code] || raise("inventory_code is required"),
                            line_id = params[:line_id])

    item = current_inventory_pool.items.where(:inventory_code => inventory_code).first
    line = @contract.lines.find(line_id)

    if item and line and line.model_id == item.model_id
      line.update_attributes(item: item)
      @error = {:message => line.errors.full_messages.join(', ')} unless line.valid?
    else
      unless inventory_code.blank?
        @error = if item and line and line.model_id != item.model_id
          {:message => _("The inventory code %s is not valid for this model" % inventory_code)}
        elsif line
          {:message => _("The item with the inventory code '%s' was not found" % inventory_code)}
        elsif item
          {:message => _("The line was not found")}
        else 
          {:message => _("Assigning the inventory code fails")}
        end
      end
      line.update_attributes(item: nil)
    end
    
    respond_to do |format|
      format.json {
        if @error.blank? 
          render :json => view_context.json_for(line, {:preset => :hand_over_line})
        else
          render :json => view_context.error_json(@error), status: 500
        end
      }
    end 
  end

  def add_option(start_date = params[:start_date], end_date = params[:end_date])
    if request.post?
      option = current_inventory_pool.options.find(params[:option_id])
      
      # FIXME go through @contract.add_lines ??
      option_line = @contract.option_lines.create(:option => option, :quantity => 1, :start_date => start_date, :end_date => end_date)
      if option_line.errors.size > 0
        flash[:error] = option_line
      end
      redirect_to :action => 'show', :id => @contract
    else
      redirect_to :controller => 'options', 
                  :layout => 'modal',
                  :start_date => start_date,
                  :end_date => end_date,
                  :source_path => request.env['REQUEST_URI']
    end
  end

  def add_line( quantity = (params[:quantity] || 1).to_i,
                start_date = params[:start_date].try{|x| Date.parse(x)} || Date.today,
                end_date = params[:end_date].try{|x| Date.parse(x)} || Date.tomorrow,
                model_id = params[:model_id],
                model_group_id = params[:model_group_id],
                option_id = params[:option_id],
                code = params[:code],
                line_ids = params[:line_ids])
    
    # find model or option 
    model = if not code.blank?
      item = current_inventory_pool.items.where(:inventory_code => code).first 
      item.model if item
    elsif model_group_id
      Template.find(model_group_id) # TODO scope current_inventory_pool ?
    elsif model_id
      current_inventory_pool.models.find(model_id)
    end
    unless model
      option = current_inventory_pool.options.find option_id if option_id
      option ||= current_inventory_pool.options.where(:inventory_code => code).first
    end
    
    # create new line or assign
    if model
      # try to assign for (selected)line_ids first
      line = @contract.lines.where(:id => line_ids, :model_id => item.model, :item_id => nil).first if line_ids and code
      # try to assign to contract lines of the customer
      line ||= @contract.lines.where(:model_id => model.id, :item_id => nil).order(:start_date).first if code
      # add new line
      line ||= model.add_to_document(@contract, @user, quantity, start_date, end_date, current_inventory_pool).first
      @error = {:message => line.errors.values.join} if model_group_id.nil? and item and line and not line.update_attributes(item: item)
    elsif option
      if line = @contract.lines.where(:option_id => option.id, :start_date => start_date, :end_date => end_date).first
        line.quantity += quantity
        line.save
      # FIXME go through @contract.add_lines ??
      elsif not line = @contract.option_lines.create(:option => option, :quantity => quantity, :start_date => start_date, :end_date => end_date)
        @error = {:message => _("The option could not be added" % code)}
      end
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
          render :json => view_context.json_for(Array(line), {:preset => :hand_over_line})
        else
          render :json => view_context.error_json(@error), status: 500
        end
      } 
    end
  end

  def swap_model_line
    generic_swap_model_line(@contract)
  end

  def swap_user
    if params[:swap_user_id].blank?
      flash[:notice] = _("User must be selected")
    else
      new_user = current_inventory_pool.users.find(params[:swap_user_id])
      lines_for_new_contract = @contract.contract_lines.find(params[:line_ids].split(',')) if params[:line_ids]
      if new_user and lines_for_new_contract
        new_contract = new_user.get_current_contract(current_inventory_pool)
        lines_for_new_contract.each do |cl|
          cl.update_attributes(:contract => new_contract)
        end
        flash[:notice] = _("The selected lines have been moved")
      end
    end  

    respond_to do |format|
     format.json { render :json => {new_user_id: new_user.id} }
    end
  end   

end
