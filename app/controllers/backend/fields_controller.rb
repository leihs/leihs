class Backend::FieldsController < Backend::BackendController
    
  def index

    fields = Field.accessible_by current_user, current_inventory_pool

    respond_to do |format|
      format.json { render :json => view_context.json_for(fields) }
    end

  end  

end
