class Backend::LocationsController < Backend::BackendController

  before_filter :pre_load

  def index
    # OPTIMIZE 0501 
    params[:sort] ||= 'building_name'
    params[:sort_mode] ||= 'ASC'
    params[:sort_mode] = params[:sort_mode].downcase.to_sym

    @locations = Location.search params[:query], { :star => true, :page => params[:page], :per_page => $per_page,
                                                   :order => params[:sort], :sort_mode => params[:sort_mode],
                                                   :with => { :inventory_pool_ids => current_inventory_pool.id } }
  end

  def show
    @location ||= Location.new
  end

  # TODO 1108** still used?
  def create
    @location = Location.new
    update
  end

  # TODO 1108** still used?
  def update
    @location.update_attributes(params[:location])
    redirect_to(backend_inventory_pool_locations_path)
  end

  def destroy
    @location.destroy
    redirect_to(backend_inventory_pool_locations_path)
  end

#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:location_id] if params[:location_id]
    @location = current_inventory_pool.locations.find(params[:id]) if params[:id]

    @tabs = []
    @tabs << :location_backend if @location
  end

end
  
