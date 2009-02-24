class Backend::TakeBackController < Backend::BackendController

  before_filter :pre_load

  def index
    if params[:remind]
      visits = current_inventory_pool.remind_visits
    else
      visits = current_inventory_pool.take_back_visits
    end
                                              
    unless params[:query].blank?
      @contracts = current_inventory_pool.contracts.signed_contracts.search(params[:query])

      # TODO search by inventory_code

      # OPTIMIZE named_scope intersection?
      visits = visits.select {|v| v.contract_lines.any? {|l| @contracts.include?(l.contract) } }
    end

    visits = visits.select {|v| v.user == @user} if @user # OPTIMIZE named_scope intersection?

    @visits = visits.paginate :page => params[:page], :per_page => $per_page
  end

  # get current contracts for a given user
  def show
    @contract_lines = @user.get_signed_contract_lines
    @contract_lines.sort! {|a,b| a.end_date <=> b.end_date}
  end

  # Close definitely the contract
  def close_contract
    if request.post?
      @lines = current_inventory_pool.contract_lines.find(params[:lines]) if params[:lines]
      @lines ||= []
      @contracts = @lines.collect(&:contract).uniq
      
      # set the return dates to the given contract_lines
      @lines.each { |l| l.update_attribute :returned_date, Date.today }
      
      @contracts.each do |c|
        c.close if c.lines.all? { |l| !l.returned_date.nil? }
      end
      
      render :action => 'print_contract', :layout => $modal_layout_path
    else
      @lines = current_inventory_pool.contract_lines.find(params[:lines].split(',')) if params[:lines]
      render :layout => $modal_layout_path
    end    
  end
  
  
  # given an inventory_code, searches for the matching contract_line
  def assign_inventory_code
    contract_lines = @user.get_signed_contract_lines
    contract_lines.sort! {|a,b| a.end_date <=> b.end_date} # TODO select first to take back

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
      redirect_to :action => 'show'
    else
      render :layout => $modal_layout_path
    end
  end

  def time_lines
    contract = @user.contract_lines.find(Array(params[:lines]).first).contract # NOTE always assuming there is just 1 line
    generic_time_lines(contract, false, true)
  end    

  def timeline
    @timeline_xml = @user.timeline
    render :nothing => true, :layout => 'backend/' + $theme + '/modal_timeline'
  end

  private
  
  def pre_load
    @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]
  end
    
end
