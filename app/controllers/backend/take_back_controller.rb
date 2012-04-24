class Backend::TakeBackController < Backend::BackendController

  before_filter do
    @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
  end

######################################################################

  # get current contracts for a given user
  def show
    @visits = @user.visits.take_back.scoped_by_inventory_pool_id(current_inventory_pool)
    add_visitor(@user)
  end

  # Close definitely the contract
  def close_contract(line_ids = params[:line_ids]  || raise("line_ids is required"),
                     returned_quantity = params[:returned_quantity])

    lines = current_inventory_pool.contract_lines.find(line_ids)

    # set the return dates to the given contract_lines
    lines.each do |l|
      l.update_attributes(:returned_date => Date.today) 
      l.item.histories.create(:user => current_user, :text => _("Item taken back"), :type_const => History::ACTION) unless l.item.is_a? Option
    end

    # fetch all envolved contracts    
    contracts = lines.collect(&:contract).uniq 

    # close the envolved contracts where all lines are finally returned
    contracts.each do |c|
      c.close if c.lines.all? { |l| !l.returned_date.nil? }
    end

    respond_to do |format|
      format.json { render :partial => "backend/contracts/index", :locals => {contracts: contracts}  }
    end

=begin
    params[:layout] = "modal"
    if request.post?
      # TODO 2702** merge duplications
      @lines = current_inventory_pool.contract_lines.find(line_ids) if line_ids
      @lines ||= []
      
      if returned_quantity
        returned_quantity.each_pair do |k,v|
          line = @lines.detect {|l| l.id == k.to_i }
          if line and v.to_i < line.quantity
            # NOTE: line is an OptionLine, since the ItemLine's quantity is always 1
            new_line = line.dup # NOTE use .dup instead of .clone (from Rails 3.1)
            new_line.quantity -= v.to_i
            new_line.save
            line.update_attributes(:quantity => v.to_i)
          end
        end
      end
      
      @contracts = @lines.collect(&:contract).uniq
      
      # set the return dates to the given contract_lines
      @lines.each { |l|
        l.update_attributes(:returned_date => Date.today) 
        l.item.histories.create(:user => current_user, :text => _("Item taken back"), :type_const => History::ACTION) unless l.item.is_a? Option
      }
      
      # trigger model availability recomputation
      models = []
      @lines.each do |line|
        if line.is_a?(ItemLine) and not models.include?(line.model)
          models << line.model
          line.save
        end
      end

      
      @contracts.each do |c|
        c.close if c.lines.all? { |l| !l.returned_date.nil? }
      end

      if current_inventory_pool.print_contracts
        render :action => 'print_contract'
      else
        redirect_to :action => 'index'
      end
    else
      # TODO 2702** merge duplications
      @lines = current_inventory_pool.contract_lines.find(params[:lines].split(',')) if params[:lines]
      if returned_quantity
        returned_quantity.each_pair do |k,v|
          line = @lines.detect {|l| l.id == k.to_i }
          line.quantity = v.to_i if line and v.to_i < line.quantity
        end
      end
    end    
=end                    
  end
  
  def things_to_return(term = params[:term])
    contract_lines = @user.get_signed_contract_lines(current_inventory_pool.id)
    matched_lines = contract_lines.select do |line|
      case line.type
      when "ItemLine"
        line if (line.item.inventory_code.match(/#{term}/i) or line.item.model.name.match(/#{term}/i) or term.blank?)  
      when "OptionLine"
        line if (line.item.inventory_code.match(/#{term}/i) or line.item.name.match(/#{term}/i) or term.blank?)
      end
    end
    respond_to do |format|
      format.json { render :partial => "backend/contracts/lines.json.rjson", :locals => {:lines => matched_lines} }
    end
  end
  
  # given an inventory_code, searches for the matching contract_line
  def assign_inventory_code
    contract_lines = @user.get_signed_contract_lines(current_inventory_pool.id)
    contract_lines.sort! {|a,b| [a.end_date, a.model.name] <=> [b.end_date, b.model.name] } # TODO select first to take back

    item = current_inventory_pool.items.where(:inventory_code => params[:code]).first
    unless item.nil?
      @contract_line = contract_lines.detect {|cl| cl.item_id == item.id }
    else
      # Inventory Code is not an item - might be an option...
      option = current_inventory_pool.options.where(:inventory_code => params[:code]).first
      unless option.nil?
        @contract_line = contract_lines.detect {|cl| cl.option_id == option.id }
      end
    end
    flash[:error] = _("The Inventory Code %s was not found.") % params[:code] unless @contract_line
    render :action => 'change_line'
  end

  def inspection
    @contract_line = @user.contract_lines.find(params[:line_id])
    if request.post?
      @contract_line.item.update_attributes(params[:item])
      
      @contract_line.item.log_history(params[:note], current_user.id)
      render :nothing => true
    else
      params[:layout] = "modal"
    end
  end

  def time_lines
    generic_time_lines(@user, false, true)
  end    
    
end
