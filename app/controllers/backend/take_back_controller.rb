class Backend::TakeBackController < Backend::BackendController
  
  def index
#      @signed_contracts = Contract.signed_contracts

      @grouped_lines = ContractLine.ready_for_take_back                                           
                                              
   # TODO search/filter                                           
      
  end

  # get current contracts for a given user
  def show
    @user = User.find(params[:id])
    @contract_lines = @user.get_signed_contract_lines
    
    @contract_lines.sort! {|a,b| a.end_date <=> b.end_date}
  end

  # set the return dates to the given contract_lines
  def update_contract
    if request.post?
      @lines = ContractLine.find(params[:lines].split(','))
      @lines.each { |l| l.update_attribute :returned_date, Date.today }
      
      # TODO generate new pdf for the contracts       
      redirect_to :action => 'index'          
    else
      #@user = User.find(params[:id])
      #@lines = @user.get_signed_contract_lines.find(params[:lines].split(','))
      @lines = ContractLine.find(params[:lines].split(','))
      render :layout => $modal_layout_path
    end    
  end
  
  # given an inventory_code, searches for the matching contract_line
  def assign_inventory_code
    if request.post?
      item = Item.find(:first, :conditions => { :inventory_code => params[:code] })
      unless item.nil?
        @user = User.find(params[:id])
        contract_lines = @user.get_signed_contract_lines
    
        contract_lines.sort! {|a,b| a.end_date <=> b.end_date} # TODO select first to take back
        @contract_line = contract_lines.find {|cl| cl.item_id == item.id }
        @contract = @contract_line.contract # TODO optimize errors report

      end
      render :action => 'change_line'
    end
  end

    
end
