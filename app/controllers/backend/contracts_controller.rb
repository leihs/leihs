class Backend::ContractsController < Backend::BackendController
  
  before_filter :preload

  def index
    contracts = current_inventory_pool.contracts
    contracts = contracts & @user.contracts if @user

    case params[:filter]
      when "signed"
        contracts = contracts.signed_contracts
      when "closed"
        contracts = contracts.closed_contracts
    end

    unless params[:query].blank?
      @contracts = contracts.search(params[:query], :page => params[:page], :per_page => $per_page)
    else
      @contracts = contracts.paginate :page => params[:page], :per_page => $per_page
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
