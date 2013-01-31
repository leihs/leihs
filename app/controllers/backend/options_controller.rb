class Backend::OptionsController < Backend::BackendController

  before_filter do
    params[:id] ||= params[:option_id] if params[:option_id]
    @option = current_inventory_pool.options.find(params[:id]) if params[:id]
  end

######################################################################
  
  def show
  end
  
  def new
    @option = Option.new
    render :action => 'show'
  end
  
  def create
    @option = Option.new(:inventory_pool => current_inventory_pool)
    update
  end

  def update
    @option.update_attributes(params[:option])
    if params[:source_path]
      redirect_to params[:source_path]
    else
      redirect_to backend_inventory_pool_models_path(current_inventory_pool)
    end
  end

  def destroy
    @option.destroy
    redirect_to backend_inventory_pool_models_path(current_inventory_pool)
  end
    
end
