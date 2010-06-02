class Backend::TakeBackController < Backend::BackendController

  before_filter :pre_load

  def index
    visits = if params[:remind]
               current_inventory_pool.take_back_visits(Date.yesterday)
             else
               current_inventory_pool.take_back_visits
             end
                                              
    unless params[:query].blank?
      @contracts = Contract.sphinx_signed.search params[:query], { :star => true, :page => params[:page], :per_page => $per_page,
                                                                   :with => { :inventory_pool_id => current_inventory_pool.id } }

      # TODO search by inventory_code

      # OPTIMIZE named_scope intersection?
      visits = visits.select {|v| v.contract_lines.any? {|l| @contracts.include?(l.contract) } }
    end

    visits = visits.select {|v| v.user == @user} if @user # OPTIMIZE named_scope intersection?

    @visits = visits.paginate :page => params[:page], :per_page => $per_page

    respond_to do |format|
      format.html
      format.js { search_result_rjs(@contracts) }
    end
  end

  # get current contracts for a given user
  def show
    @contract_lines = @user.get_signed_contract_lines(current_inventory_pool.id)
    @contract_lines.sort! {|a,b| [a.end_date, a.model.name] <=> [b.end_date, b.model.name] }
    add_visitor(@user)
  end

  # Close definitely the contract
  def close_contract
    if request.post?
      # TODO 2702** merge duplications
      @lines = current_inventory_pool.contract_lines.find(params[:lines]) if params[:lines]
      @lines ||= []
      if params[:returned_quantity]
        params[:returned_quantity].each_pair do |k,v|
          line = @lines.detect {|l| l.id == k.to_i }
          if line and v.to_i < line.quantity
            new_line = line.clone
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
      
      @contracts.each do |c|
        c.close if c.lines.all? { |l| !l.returned_date.nil? }
      end
      
      params[:layout] = "modal"
      render :action => 'print_contract'
    else
      # TODO 2702** merge duplications
      @lines = current_inventory_pool.contract_lines.find(params[:lines].split(',')) if params[:lines]
      if params[:returned_quantity]
        params[:returned_quantity].each_pair do |k,v|
          line = @lines.detect {|l| l.id == k.to_i }
          line.quantity = v.to_i if line and v.to_i < line.quantity
        end
      end
      params[:layout] = "modal"
    end    
  end
  
  
  # given an inventory_code, searches for the matching contract_line
  def assign_inventory_code
    contract_lines = @user.get_signed_contract_lines(current_inventory_pool.id)
    contract_lines.sort! {|a,b| [a.end_date, a.model.name] <=> [b.end_date, b.model.name] } # TODO select first to take back

    item = current_inventory_pool.items.first(:conditions => { :inventory_code => params[:code] })
    unless item.nil?
      @contract_line = contract_lines.detect {|cl| cl.item_id == item.id }
    else
      # Inventory Code is not an item - might be an option...
      option = current_inventory_pool.options.first(:conditions => { :inventory_code => params[:code] })
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

  private
  
  def pre_load
    @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
  end
    
end
