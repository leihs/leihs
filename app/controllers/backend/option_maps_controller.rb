class Backend::OptionMapsController < Backend::BackendController

  before_filter :pre_load

  def index
    @option_maps = current_inventory_pool.option_maps.search(params[:query], :page => params[:page], :per_page => $per_page)
  end
  
  def show
  end
  
  def new
    @option_map = OptionMap.new
    render :action => 'show'
  end
  
  def create
    @option_map = OptionMap.new(:inventory_pool => current_inventory_pool)
    update
  end

  def update
    @option_map.update_attributes(params[:option_map])
    redirect_to(backend_inventory_pool_option_maps_path)
  end

  def destroy
    @option_map.destroy
    redirect_to(backend_inventory_pool_option_maps_path)
  end
  
  
  private
  
  def pre_load
    params[:id] ||= params[:option_map_id] if params[:option_map_id]
    @option_map = current_inventory_pool.option_maps.find(params[:id]) if params[:id]
  end
  
end
