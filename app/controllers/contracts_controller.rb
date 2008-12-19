class ContractsController < FrontendController

  before_filter :pre_load

  def show(sort =  params[:sort] || "model", dir =  params[:dir] || "ASC")
    respond_to do |format|
      format.ext_json { render :json => @contract.to_json(:include => {
                                                            :contract_lines => { :include => { :model => {}, 
                                                                                               :item => { } # TODO 17** :include => :inventory_pool (delegate in item.rb is not working)
                                                                                             },
                                                                            :except => [:created_at, :updated_at]}
                                                          } ) }
    end
  end

########################################################
  
  private
  
  def pre_load
      @contract = current_user.contracts.find(params[:id]) if params[:id]
  end  

end
