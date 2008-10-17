class Backend::ContractsController < Backend::BackendController
  
  before_filter :preload

#  active_scaffold :contract do |config|
##    config.columns = [:manufacturer, :name, :model_groups, :locations]
#    config.columns.each { |c| c.collapsed = true }
#
#    config.actions.exclude :create, :update, :delete
#  end
#
#  # filter for active_scaffold (through locations)
#  def conditions_for_collection
#    {:inventory_pool_id => current_inventory_pool.id}
#  end

#################################################################  

  def index
    contracts = current_inventory_pool.contracts

    if !params[:query].blank?
      @contracts = contracts.find_by_contents("*" + params[:query] + "*", :page => params[:page], :per_page => Contract.per_page)
    else
      contracts = contracts & @user.contracts if @user
      @contracts = contracts.paginate :page => params[:page], :per_page => Contract.per_page
    end

  end
  
  def show
    respond_to do |format|
      # format.html
      format.pdf { send_data(render(:layout => false), :filename => "contract_#{@contract.id}.pdf") }
    end
  end


  private
  
  def preload
    @contract = current_inventory_pool.contracts.find(params[:id]) if params[:id]
  end
  
end
