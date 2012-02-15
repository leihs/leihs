class Backend::OptionsController < Backend::BackendController

  before_filter do
    params[:id] ||= params[:option_id] if params[:option_id]
    @option = current_inventory_pool.options.find(params[:id]) if params[:id]
  end

######################################################################

  def index
    @options = current_inventory_pool.options.search2(params[:query]).paginate(:page => params[:page], :per_page => $per_page)

    if params[:source_path] # we are in a greybox
      @start_date = Date.parse(params[:start_date])
      @end_date = Date.parse(params[:end_date])
    end

    respond_to do |format|
      format.html
      format.js { search_result_rjs(@options) }
    end

  end
  
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
# TODO 1602**      
#      post(params[:source_path], :option_id => @option.id)
      redirect_to params[:source_path]
    else
      redirect_to(backend_inventory_pool_options_path)
    end
  end

  def destroy
    @option.destroy
    redirect_to(backend_inventory_pool_options_path)
  end
    
end
