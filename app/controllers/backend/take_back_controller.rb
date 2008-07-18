class Backend::TakeBackController < Backend::BackendController
  
  def index
                                              
    if params[:search]
      params[:search] = "*#{params[:search]}*" # search with partial string
      @contracts = current_inventory_pool.contracts.signed_contracts.find_by_contents(params[:search])

      # OPTIMIZE named_scope intersection?
      @visits = current_inventory_pool.take_back_visits.select {|v| v.contract_lines.any? {|l| @contracts.include?(l.contract) } }
      
    elsif params[:user_id]
      @user = User.find(params[:user_id]) # TODO scope current_inventory_pool

      # OPTIMIZE named_scope intersection?
      @visits = current_inventory_pool.take_back_visits.select {|v| v.user == @user}
      
    elsif params[:remind] #temp#
      @visits = current_inventory_pool.remind_visits
      
    else
      @visits = current_inventory_pool.take_back_visits
      
    end
    
    render :partial => 'visits' if request.post?
  end

  # get current contracts for a given user
  def show
    @user = User.find(params[:id]) # TODO scope current_inventory_pool
    @contract_lines = @user.get_signed_contract_lines
    
    @contract_lines.sort! {|a,b| a.end_date <=> b.end_date}
  end

  # Close definitely the contract
  def close_contract
    if request.post?
      # TODO collect the set of contracts
      @lines = ContractLine.find(params[:lines]) if params[:lines] # TODO scope current_inventory_pool
      @contract = @lines.first.contract # TODO iterate @lines.collect(&:contract)

      # TODO make sure the coherence between paper and storage
      @contract.close if @contract.lines.all? { |l| !l.returned_date.nil? }
      
      redirect_to :action => 'index'          
    else
      #@user = User.find(params[:id])
      #@lines = @user.get_signed_contract_lines.find(params[:lines].split(','))
      @lines = ContractLine.find(params[:lines].split(',')) # TODO scope current_inventory_pool
      render :layout => $modal_layout_path
    end    
  end

  # Creating the contract to print
  def print_contract
#    @lines = @contract.contract_lines.find(params[:lines]) if params[:lines]
    @lines = ContractLine.find(params[:lines]) if params[:lines] # TODO scope current_inventory_pool

    # set the return dates to the given contract_lines
    # TODO reverse if contract is not signed !!!!!!
    @lines.each { |l| l.update_attribute :returned_date, Date.today }
          
    @contract = @lines.first.contract # TODO iterate @lines.collect(&:contract)
    # TODO generate new pdf for the contracts
    @contract.to_pdf
    send_data @contract.printouts.last.pdf, :filename => "contract.pdf", :type => "application/pdf"
  end  
  
  
  # given an inventory_code, searches for the matching contract_line
  def assign_inventory_code
    if request.post?
      item = current_inventory_pool.items.find(:first, :conditions => { :inventory_code => params[:code] })
      unless item.nil?
        @user = User.find(params[:id]) # TODO scope current_inventory_pool
        contract_lines = @user.get_signed_contract_lines
    
        contract_lines.sort! {|a,b| a.end_date <=> b.end_date} # TODO select first to take back
        @contract_line = contract_lines.detect {|cl| cl.item_id == item.id }
        @contract_line.update_attribute :start_date, Date.today

        @contract = @contract_line.contract # TODO optimize errors report

      end
      render :action => 'change_line'
    end
  end

  # TODO temp timeline
  def timeline
    @user = User.find(params[:id]) # TODO scope current_inventory_pool
    @timeline_xml = @user.timeline
    render :text => "", :layout => 'backend/' + $theme + '/modal_timeline'
  end
    
end
