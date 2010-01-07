class Backend::ContractsController < Backend::BackendController
  
  before_filter :preload

  def index
    contracts = current_inventory_pool.contracts
    contracts = contracts & @user.contracts if @user # TODO 1209** @user.contracts.by_inventory_pool(current_inventory_pool)

    case params[:filter]
      when "signed"
        contracts = contracts.signed
      when "closed"
        contracts = contracts.closed

      #TODO: Clean up, really.
      # This is meant to show contracts with a specific return or start date,
      # to make it easier for Michi to reconcile deposits with his "Kassenbuch,
      when "deposit_relevant"
        day = Date.yesterday
        day = params[:day] if params[:day]
        #lines = ContractLine.find(:all, :conditions => { :returned_date => day } )
        #lines += ContractLine.find(:all, :conditions => { :start_date => day } )
        #ids = []
        #lines.each do |l|
        #  ids << l.contract_id if l.contract.inventory_pool = current_inventory_pool
        #end
        #ids.uniq!

        # Why the heck does the ugly SQL below work and the beautiful (*cough*, ahem) Ruby above doesn't?
        sql = "id in ( select distinct(contract_id) from contract_lines where (returned_date = ? or start_date = ?) and contract_id in ( select id from contracts where inventory_pool_id = ? ))"
        contracts = Contract.find(:all, :conditions => [sql, day, day, current_inventory_pool.id] )
      else
        contracts = contracts.signed + contracts.closed
    end

    @contracts = contracts.search(params[:query], {:page => params[:page], :per_page => $per_page})
  end
  
  def show
    respond_to do |format|
			# Evil hack? We need the contract information in that other template as well
			if params[:template] == "value_list"
        format.pdf { send_data(render(:template => 'backend/contracts/value_list', :layout => false), :type => 'application/pdf', :filename => "value_list_#{@contract.id}.pdf") }
			elsif params[:template] == "value_list_for_models"
        format.pdf { send_data(render(:template => 'backend/contracts/value_list_for_models', :layout => false), :type => 'application/pdf', :filename => "maximum_value_list_#{@contract.id}.pdf") }

      else
      # format.html
        format.pdf { send_data(render(:layout => false), :type => 'application/pdf', :filename => "contract_#{@contract.id}.pdf") }
			end
    end
  end

  private
  
  def preload
    @contract = current_inventory_pool.contracts.find(params[:id]) if params[:id]
  end
  
end
