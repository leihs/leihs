class Backend::ContractsController < Backend::BackendController
  
  before_filter :preload
  
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
