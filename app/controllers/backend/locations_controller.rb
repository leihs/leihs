class Backend::LocationsController < Backend::BackendController

  before_filter :pre_load


  def index
    locations = current_inventory_pool.locations
    
    unless params[:query].blank?
      @locations = locations.find_by_contents("*" + params[:query] + "*", :page => params[:page], :per_page => $per_page)
    else
      @locations = locations.paginate :page => params[:page], :per_page => $per_page      
    end
  end

  def show
  end

  def new
    @location = Location.new
    render :action => 'show'
  end

  def update
    # TODO 22** set new main (default) location
    @location ||= Location.new(:inventory_pool => current_inventory_pool)
    @location.update_attributes(params[:location])
    redirect_to(backend_locations_path)
  end

  def destroy
    @location.destroy
    redirect_to(backend_locations_path)
  end

#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:location_id] if params[:location_id]
    @location = current_inventory_pool.locations.find(params[:id]) if params[:id]
  end

end
  
