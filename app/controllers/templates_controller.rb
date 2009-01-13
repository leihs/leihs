class TemplatesController < FrontendController

  def index
    respond_to do |format|
      format.ext_json { render :json => current_user.templates.to_json(:methods => [:text,
                                                                                    :leaf]) }
    end
  end

  def show
    # TODO 12** through User real association
    # template = current_user.templates.find(params[:id])
    template = Template.find(params[:id])
    
    respond_to do |format|
      format.ext_json { render :json => template.model_links.to_ext_json( :include => {:model => {
                                                                          :except => [ :internal_description,
                                                                                       :info_url,
                                                                                       :maintenance_period,
                                                                                       :created_at,
                                                                                       :updated_at ],
                                                                          :include => {
                                                                              :inventory_pools => { :records => current_inventory_pools,
                                                                                                    :except => [:description,
                                                                                                                :logo_url,
                                                                                                                :contract_url,
                                                                                                                :contract_description,
                                                                                                                :created_at,
                                                                                                                :updated_at] } }
                                                                              }} ) }
    end
  end

end
