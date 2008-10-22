class Backend::TakeBackController < Backend::BackendController

  before_filter :pre_load

  def index
    if params[:remind]
      visits = current_inventory_pool.remind_visits
    else
      visits = current_inventory_pool.take_back_visits
    end
                                              
    unless params[:query].blank?
      @contracts = current_inventory_pool.contracts.signed_contracts.find_by_contents("*" + params[:query] + "*")

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
    @options = Option.find(params[:options].split(','))
    
    if request.post?
      #temp# @lines = @user.get_signed_contract_lines.find(params[:lines].split(','))
      @lines = current_inventory_pool.contract_lines.find(params[:lines]) #if params[:lines]
      @contracts = @lines.collect(&:contract).uniq #if @lines
      
      # set the return dates to the given contract_lines
      @lines.each { |l| l.update_attribute :returned_date, Date.today }
      @options.each { |o| o.update_attribute :returned_date, Date.today }
      
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
    if request.post?
      item = current_inventory_pool.items.find(:first, :conditions => { :inventory_code => params[:code] })
      unless item.nil?
        contract_lines = @user.get_signed_contract_lines
    
        contract_lines.sort! {|a,b| a.end_date <=> b.end_date} # TODO select first to take back
        @contract_line = contract_lines.detect {|cl| cl.item_id == item.id }
        @contract_line.update_attribute :start_date, Date.today

        @contract = @contract_line.contract # TODO optimize errors report
      end
      render :action => 'change_line'
    end
  end

  def broken
    if request.post?
      @item.update_attribute :status_const, Item::UNBORROWABLE 
      @item.log_history(params[:comment], current_user.id)
      redirect_to :action => 'show', :user_id => @contract.user.id
    else
      render :layout => $modal_layout_path
    end
  end

  def timeline
    @timeline_xml = @user.timeline
    render :nothing => true, :layout => 'backend/' + $theme + '/modal_timeline'
  end

  private
  
  def pre_load
    @user = current_inventory_pool.users.find(params[:user_id]) if params[:user_id]    
    @contract = Contract.find(params[:contract_id]) if params[:contract_id]
    @item = Item.find(params[:item_id]) if params[:item_id] 
  end
    
end
