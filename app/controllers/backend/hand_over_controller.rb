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
  
  def set_purpose
    if request.post?
      @contract.update_attributes(:purpose => params[:purpose])
    end
    redirect_to :action => 'show'
  end
  
  def delete_visit
    lines = params[:lines].split(",")
    lines.each {|l| @contract.remove_line(l, current_user.id) }
    respond_to do |format|
      format.js { render :json => true, :status => 200  }
    end
  end
  
  # Sign definitely the contract
  def sign_contract(line_ids = params[:line_ids] || raise("line_ids is required"),
                    note = params[:note])
    lines = @contract.contract_lines.find(line_ids)

    @contract.note = note

    respond_to do |format|
      format.json {
        if @contract.sign(lines, current_user)
          render :partial => "backend/contracts/show.json.rjson", :locals => {contract: @contract}
        else
          @error = {:message => @contract.errors.full_messages}
          render :template => "/errors/show", status: 500
        end
      }
    end
    
=begin
    if request.post?
      @contract.note = params[:note]
      @contract.sign(@lines, current_user)
      if current_inventory_pool.print_contracts
        render :action => 'print_contract'
      else
        redirect_to :action => 'index'
      end
    else
      @lines = @lines.delete_if {|l| l.item.nil? } # NOTE l could be an option_line, then l.item_id.nil? doesn't work!
      if @lines.empty?
        flash[:error] = _("No items to hand over specified. Please assign inventory codes to the items you want to hand over.")
      else
        today = Date.today
        @lines.each do |line|
          next if line.start_date == today
          line.start_date = today
          line.end_date = today if line.end_date < line.start_date
          if line.start_date_changed? and line.save
            flash[:notice] ||= []
            flash[:notice] << _("The start date has been changed for item %s") % line.item.inventory_code
          end
        end
      end
    end    
=end
  end

=begin
  # change quantity: duplicating item_line or (TODO) changing quantity for option_line
  # preventing quantity less than 1
  def change_line_quantity(quantity = [params[:quantity].to_i, 1].max)
    @contract_line = @contract.lines.find(params[:contract_line_id])

    # TODO refactor to model
    if @contract_line.is_a?(ItemLine)
      (quantity - @contract_line.quantity).times do
        new_line = @contract_line.dup # OPTIMIZE keep contract history 
        new_line.item = nil
        new_line.save
      end
      flash[:notice] = _("New lines have been generated")
    else
      @contract_line.update_attributes(:quantity => quantity)
      flash[:notice] = _("The quantity has been changed")
    end
  end
=end

=begin
  # Changes the line according to the inserted inventory code
  def change_line
    if request.post?
      # TODO refactor in the Contract model and keep track of changes

      @contract_line = current_inventory_pool.contract_lines.find(params[:contract_line_id])
      @contract = @contract_line.contract
      
      required_item_inventory_code = params[:code]
      @contract_line.item = Item.where(:inventory_code => required_item_inventory_code).first
      if @contract_line.save
        # TODO refactor in model: change = _("Changed dates for %{model} from %{from} to %{to}") % { :model => line.model.name, :from => "#{original_start_date} - #{original_end_date}", :to => "#{line.start_date} - #{line.end_date}" }
        # TODO refactor in model: log_change(change, user_id)
      else
        @contract_line.errors.each_full do |msg|
          @contract.errors.add(:base, msg)
        end
        flash[:error] = @contract.errors.full_messages
      end
    end
  end  
=end

  def update_lines(line_ids = params[:line_ids] || raise("line_ids is required"),
                   line_id_model_id = params[:line_id_model_id] || {},
                   quantity = (params[:quantity] ? [params[:quantity].to_i, 1].max : nil),
                   start_date = params[:start_date],
                   end_date = params[:end_date])
    
    ContractLine.transaction do
      lines = @contract.lines.find(line_ids)
      # TODO merge to Contract#update_line
      lines.each do |line|        
        line.start_date = Date.parse(start_date) if start_date
        line.end_date = Date.parse(end_date) if end_date

        # NOTE because cloning, this has to be the last change before saving
        if quantity
          if line.is_a?(ItemLine)
            (quantity - line.quantity).times do
              new_line = line.dup # NOTE use .dup instead of .clone (from Rails 3.1) 
              new_line.item = nil
              new_line.save # TODO log_change (not needed anymore with the new audits)
            end
          else
            line.quantity = quantity
          end
        end

        # TODO remove log changes (use the new audits)
        change = ""
        if (new_model_id = line_id_model_id[line.id.to_s]) 
          line.model = line.contract.user.models.find(new_model_id) 
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

        @contract.log_change(change, current_user.id) if line.save
      end
    end

    respond_to do |format|
      format.json {
        @visits = @user.visits.hand_over.scoped_by_inventory_pool_id(current_inventory_pool)
        render :partial => "backend/visits/index.json.rjson", locals: {visits: @visits}
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
  def assign_inventory_code (inventory_code = params[:inventory_code] || raise("inventory_code is required"),
                             line_id = params[:line_id])

    item = current_inventory_pool.items.where(:inventory_code => inventory_code).first
    line = @contract.lines.find(line_id)

    if item and line and line.model == item.model
      line.update_attributes(item: item)
    else
      @error = {:message => _("The inventory code %s is not valid for this model" % inventory_code)} if item and line and line.model != item.model
      @error ||= {:message => _("The assignment for #{line.model.name} was removed" % inventory_code)} if line and inventory_code == ""
      @error ||= {:message => _("The item with the inventory code %s was not found" % inventory_code)} if line
      @error ||= {:message => _("The line was not found")} if item
      @error ||= {:message => _("Assigning the inventory code fails")}
      line.update_attributes(item: nil)
    end
    
    respond_to do |format|
      format.json {
        if @error.blank? 
          render :partial => "backend/contracts/#{line.type.underscore}.json.rjson", :locals => {:line => line}
        else
          render :template => "/errors/show", status: 500
        end
      }
    end 
  end

  def add_option(start_date = params[:start_date], end_date = params[:end_date])
    if request.post?
      option = current_inventory_pool.options.find(params[:option_id])
      
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

=begin old
  def add_line_with_item
    @prevent_redirect = true
    item = current_inventory_pool.items.find(params[:item_id])
    params[:model_id] = item.model.id
    add_line
    params[:code] = item.inventory_code
    assign_inventory_code
    redirect_to :action => 'show'
  end
=end

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
      ModelGroup.find(model_group_id) # TODO scope current_inventory_pool ?
    elsif model_id
      current_inventory_pool.models.find(model_id)
    end
    unless model
      option = current_inventory_pool.options.find option_id if option_id
      option ||= current_inventory_pool.options.where(:inventory_code => code).first
    end
    
    # create new line
    if model
      # try to assign for line_ids first
      line = if line_ids and code
        @contract.lines.where(:id => line_ids, :model_id => item.model, :item_id => nil).first
      end
      line ||= begin
        model.add_to_document(@contract, @user, quantity, start_date, end_date, current_inventory_pool)
      end
      if model_group_id.nil? and item and line and not line.update_attributes(item: item)
        @error = {:message => line.errors.values.join}
      end
    elsif option
      if line = @contract.lines.where(:option_id => option.id, :start_date => start_date, :end_date => end_date).first
        line.quantity += quantity
        line.save
      elsif ! line = @contract.option_lines.create(:option => option, :quantity => quantity, :start_date => start_date, :end_date => end_date)
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
          render :partial => "backend/contracts/lines.json.rjson", :locals => {:lines => Array(line)}
        else
          render :template => "/errors/show", status: 500
        end
      } 
    end
  end

  def swap_model_line
    generic_swap_model_line(@contract)
  end

  def time_lines
    generic_time_lines(@contract)
  end    

  def swap_user
    if request.post?
      to_user = @user
      if params[:swap_user_id].nil?
        flash[:notice] = _("User must be selected")
      else
        new_user = current_inventory_pool.users.find(params[:swap_user_id])
        lines_for_new_contract = @contract.contract_lines.find(params[:lines].split(',')) if params[:lines]

        if new_user and lines_for_new_contract
          new_contract = new_user.get_current_contract(current_inventory_pool)
          lines_for_new_contract.each do |cl|
            cl.update_attributes(:contract => new_contract)
          end
          flash[:notice] = _("The selected lines have been moved")
          to_user = new_user
        end
      end  
      redirect_to [:backend, current_inventory_pool, to_user, :hand_over]
    else
      redirect_to backend_inventory_pool_users_path(current_inventory_pool,
                                                    :layout => 'modal',
                                                    :source_path => request.env['REQUEST_URI'])
    end
  end   

end
