class Backend::ContractsController < Backend::BackendController
  
  before_filter :preload

  def index
# working here # deposit_relevant

#    contracts = current_inventory_pool.contracts
#    contracts = contracts & @user.contracts if @user # TODO 1209** @user.contracts.by_inventory_pool(current_inventory_pool)
    with = { :inventory_pool_id => current_inventory_pool.id }
    without = {}
    
    with.merge!(:user_id => @user.id) if @user

    case params[:filter]
      when "signed"
##        contracts = contracts.signed
        with.merge!(:status_const => Contract::SIGNED)
      when "closed"
##        contracts = contracts.closed
        with.merge!(:status_const => Contract::CLOSED)

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
##        contracts = contracts.signed + contracts.closed
        without.merge!(:status_const => Contract::UNSIGNED)
    end

    # TODO 0501
    @contracts = (contracts ? contracts : Contract).search params[:query], { :star => true, :page => params[:page], :per_page => $per_page,
                                                                             :with => with, :without => without }
    respond_to do |format|
      format.html
      format.js { search_result_rjs(@contracts) }
    end
                                                                             
  end
  
  def show
    respond_to do |format|
			# Evil hack? We need the contract information in that other template as well
      require 'prawn/measurement_extensions'
      prawnto :prawn => { :page_size => 'A4', 
                          :left_margin => 25.mm,
                          :right_margin => 15.mm,
                          :bottom_margin => 15.mm,
                          :top_margin => 15.mm
                        }
    
			if params[:template] == "value_list"
        
        if @contract.status_const == Contract::SIGNED or @contract.status_const == Contract::CLOSED
          format.pdf { send_data(render(:template => 'contracts/value_list_for_items', :layout => false), :type => 'application/pdf', :filename => "value_list_for_items#{@contract.id}.pdf") }
        else       
          format.pdf { send_data(render(:template => 'backend/contracts/value_list_for_models', :layout => false), :type => 'application/pdf', :filename => "maximum_value_list_#{@contract.id}.pdf") }
        end
      else
      # format.html
        format.pdf { send_data(render(:template => 'contracts/show', :layout => false), :type => 'application/pdf', :filename => "contract_#{@contract.id}.pdf") }
			end
    end
  end

  private
  
  def preload
    @contract = current_inventory_pool.contracts.find(params[:id]) if params[:id]
  end
  
end
