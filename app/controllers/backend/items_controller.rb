class Backend::ItemsController < Backend::BackendController
  
  before_filter :pre_load

  def index
    params[:sort] ||= 'models.name'
    params[:dir] ||= 'ASC'

    if @model
      items = @model.items & current_inventory_pool.items # TODO 28** optimize intersection
    elsif @location
      items = @location.items
    else
      items = current_inventory_pool.items
    end    
    case params[:filter]
      when "in_stock"
        items = items.in_stock
      when "broken"
        items = items.broken
      when "incomplete"
        items = items.incomplete
      when "unborrowable"
        items = items.unborrowable
    end
    
    @items = items.search(params[:query], {:page => params[:page], :per_page => $per_page}, {:order => sanitize_order(params[:sort], params[:dir]), :include => [:model, :location]})
  end

  def show
  end

  def update
    @item.update_attributes(params[:item])
    redirect_to :action => 'show', :id => @item # TODO 24** redirect to the right tab
  end

#################################################################

  def location
    if request.post?
      @item.update_attribute(:location, current_inventory_pool.locations.find(params[:location_id]))
      redirect_to
    end
  end

#################################################################

  def status
  end

#################################################################

  def notes
    if request.post?
        @item.log_history(params[:note], current_user.id)
    end
  end

#################################################################


  private
  
  def pre_load
    params[:id] ||= params[:item_id] if params[:item_id]
    @item = current_inventory_pool.items.find(params[:id]) if params[:id]
    @model = current_inventory_pool.models.find(params[:model_id]) if params[:model_id]
    @location = current_inventory_pool.locations.find(params[:location_id]) if params[:location_id]

    @tabs = []
    @tabs << :location_backend if @location
    @tabs << :model_backend if @model
    @tabs << :item_backend if @item
  end

end
