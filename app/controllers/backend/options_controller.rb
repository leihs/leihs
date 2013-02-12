class Backend::OptionsController < Backend::BackendController

  before_filter do
    params[:id] ||= params[:option_id] if params[:option_id]
    @option = current_inventory_pool.options.find(params[:id]) if params[:id]
  end

######################################################################
  
  def show
    respond_to do |format|
      format.json {
        render json: view_context.hash_for(@option, {:inventory_code => true,
                                                     :price => true})
      }
    end
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
    respond_to do |format|
      format.json {
        if @option.update_attributes(params[:option])
          show
        else
          render :text => @option.errors.full_messages.uniq.join(", "), :status => :bad_request
        end
      }
    end
  end

  def destroy
    @option.destroy
    redirect_to backend_inventory_pool_models_path(current_inventory_pool)
  end
    
end
