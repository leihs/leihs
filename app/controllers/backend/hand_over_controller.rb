class Backend::HandOverController < Backend::BackendController

  before_filter :pre_load

  def index
    
    if params[:search]
      params[:search] = "*#{params[:search]}*" # search with partial string
      @contracts = current_inventory_pool.contracts.new_contracts.find_by_contents(params[:search])

      # OPTIMIZE display only effective visits (i.e. for a given model name, ...)
      # OPTIMIZE named_scope intersection?
      @visits = current_inventory_pool.hand_over_visits.select {|v| v.contract_lines.any? {|l| @contracts.include?(l.contract) } }

    elsif params[:user_id]
      # OPTIMIZE named_scope intersection?
      @visits = current_inventory_pool.hand_over_visits.select {|v| v.user == @user}
    else
      
      @visits = current_inventory_pool.hand_over_visits
    end
    
    render :partial => 'visits' if request.post?                                          
  end

  # get current open contract for a given user
  def show
    @contract.contract_lines.sort! #temp# redundant
  end
  
  def delete_visit
    params[:lines].each {|l| @contract.remove_line(l, current_user.id) }
    redirect_to :action => 'index'
  end
  
  # Sign definitely the contract
  def sign_contract
    #@user = User.find(params[:user_id])
    #@lines = @user.get_signed_contract_lines.find(params[:lines].split(','))
    @lines = @contract.contract_lines.find(params[:lines].split(','))
    if request.post?
      @contract.sign(@lines)
      redirect_to :action => 'print_contract', :id => @contract.id #'index'
    else
      @lines = @lines.delete_if {|l| l.item.nil? }
      render :layout => $modal_layout_path
    end    
  end

  # Creating the contract to print
  def print_contract
    if request.post?
      #old# send_data @contract.printouts.last.pdf, :filename => "contract.pdf", :type => "application/pdf"
      send_data @contract.to_pdf, :filename => "contract_#{@contract.id}.pdf", :type => "application/pdf"
    else
      render :layout => $modal_layout_path
    end    
  end

  # Changes the line according to the inserted inventory code
  def change_line
    if request.post?
      # TODO refactor in the Contract model and keep track of changes

      @contract_line = ContractLine.find(params[:contract_line_id]) # TODO scope current_inventory_pool
      @contract = @contract_line.contract
      
      required_item_inventory_code = params[:code]
      @contract_line.item = Item.find(:first, :conditions => { :inventory_code => required_item_inventory_code})
      @contract_line.start_date = Date.today
      @start_date_changed = @contract_line.start_date_changed?
      if @contract_line.save
        # TODO refactor in model: change = _("Changed dates for %{model} from %{from} to %{to}") % { :model => line.model.name, :from => "#{original_start_date} - #{original_end_date}", :to => "#{line.start_date} - #{line.end_date}" }
        # TODO refactor in model: log_change(change, user_id)
      else
        @contract_line.errors.each_full do |msg|
          @contract.errors.add_to_base msg
        end
      end
      
#      render :partial => 'lines'
    end
  end  

  # given an inventory_code, searches for a matching contract_line
  def assign_inventory_code
    if request.post?
      item = current_inventory_pool.items.find(:first, :conditions => { :inventory_code => params[:code] })
      model = item.model unless item.nil?
      unless model.nil?
        contract_line = @contract.contract_lines.find(:first,
                                                     :conditions => { :model_id => model.id,
                                                                      :item_id => nil })
        unless contract_line.nil?
          params[:contract_line_id] = contract_line.id.to_s
          change_line
        end
      end
      render :action => 'change_line'
    end
  end

  
  def add_line
    generic_add_line(@contract, @contract.id)
  end

  def swap_model_line
    generic_swap_model_line(@contract, @contract.id)
  end

  def time_lines
    generic_time_lines(@contract, @contract.id)
  end    

  # remove a contract line for a given contract
  def remove_lines
    generic_remove_lines(@contract, @contract.id)
  end  

  # TODO temp timeline
  def timeline
    @timeline_xml = @contract.timeline
    render :text => "", :layout => 'backend/' + $theme + '/modal_timeline'
  end
    
  private
  
  def pre_load
    @contract = current_inventory_pool.contracts.find(params[:id]) if params[:id] # TODO scope new_contracts ?
    @user = User.find(params[:user_id]) if params[:user_id] # TODO scope current_inventory_pool
    @contract ||= @user.get_current_contract(current_inventory_pool) if @user
  end


end
