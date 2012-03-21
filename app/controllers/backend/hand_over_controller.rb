class Backend::HandOverController < Backend::BackendController

  before_filter do
    @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
    #tmp# @contract = @user.get_current_contract(current_inventory_pool) if @user
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
  def sign_contract
    @lines = @contract.contract_lines.find(params[:lines].split(',')) if params[:lines]
    @lines ||= []
    params[:layout] = "modal"
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
  end

  # change quantity: duplicating item_line or (TODO) changing quantity for option_line
  # preventing quantity less than 1
  def change_line_quantity(quantity = [params[:quantity].to_i, 1].max)
    @contract_line = @contract.lines.find(params[:contract_line_id])

    # TODO refactor to model
    if @contract_line.is_a?(ItemLine)
      (quantity - @contract_line.quantity).times do
        new_line = @contract_line.clone # OPTIMIZE keep contract history 
        new_line.item = nil
        new_line.save
      end
      flash[:notice] = _("New lines have been generated")
    else
      @contract_line.update_attributes(:quantity => quantity)
      flash[:notice] = _("The quantity has been changed")
    end
  end

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

  # given an inventory_code, searches for a matching contract_line
  # and if not found, adds an option
  def assign_inventory_code (inventory_code = params[:inventory_code])
    binding.pry
    
    item = current_inventory_pool.items.where(:inventory_code => inventory_code).first
    
    unless item.nil?
      if @contract.items.include?(item)
          flash[:error] = _("The item is already in the current contract.")
      elsif item.parent 
        flash[:error] = _("This item is part of package %s.") % item.parent.inventory_code
      else
        contract_line = @contract.contract_lines.where(:model_id => item.model.id, :item_id => nil).first
        unless contract_line.nil?
          params[:contract_line_id] = contract_line.id.to_s
          flash[:notice] = _("Inventory Code assigned")
          change_line
        else
          #2207: No question should be asked @new_item = item
          @prevent_redirect = true
          params[:model_id] = item.model.id
          add_line
          inventory_code = item.inventory_code
          assign_inventory_code
          flash[:notice] = _("New item added to contract.")
          @contract_line = @contract.contract_lines.first
          render :action => 'change_line'
        end
      end
    else 
      # Inventory Code is not an item - might be an option...
      # Increment quantity if the option is already present
      option = current_inventory_pool.options.where(:inventory_code => inventory_code).first
      if option
        conditions = {:option_id => option, :start_date => params[:start_date], :end_date => params[:end_date]}
        @option_line = @contract.option_lines.where(conditions).first
        if @option_line
          @option_line.increment!(:quantity)
        else
          @option_line = @contract.option_lines.create(conditions)
        end
                                                                          
        flash[:notice] = _("Option %s added.") % option.name
      else
        flash[:error] = _("The Inventory Code %s was not found.") % params[:inventory_code]
      end   
    end
    
    render :action => 'change_line' unless @prevent_redirect # TODO 29**
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

  # TODO 29**
  def add_line_with_item
    @prevent_redirect = true
    item = current_inventory_pool.items.find(params[:item_id])
    params[:model_id] = item.model.id
    add_line
    params[:code] = item.inventory_code
    assign_inventory_code
    redirect_to :action => 'show'
  end

  def add_line
    generic_add_line(@contract)
  end

  def swap_model_line
    generic_swap_model_line(@contract)
  end

  def time_lines
    generic_time_lines(@contract)
  end    

  # remove a contract line for a given contract
  def remove_lines
    generic_remove_lines(@contract)
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
