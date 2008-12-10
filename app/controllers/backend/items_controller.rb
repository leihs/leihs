class Backend::ItemsController < Backend::BackendController
  
  before_filter :pre_load

  def index

    if @model
      items = @model.items & current_inventory_pool.items # TODO 28** optimize intersection
    else
      items = current_inventory_pool.items
    end    

    case params[:filter]
      when "broken"
        items = items.broken
      when "incomplete"
        items = items.incomplete
      when "unborrowable"
        items = items.unborrowable
    end
    
    unless params[:query].blank?
      @items = items.search(params[:query], :page => params[:page], :per_page => $per_page)
    else
      @items = items.paginate :page => params[:page], :per_page => $per_page      
    end
  end

  def show
    render :layout => $modal_layout_path if params[:layout] == "modal"
  end

  def update
    @item.update_attributes(params[:item])
    redirect_to :action => 'show', :id => @item # TODO redirect to the right tab
  end

#################################################################

  def location
    #render :layout => false
  end
  
  def set_location
    @item.update_attribute(:location, current_inventory_pool.locations.find(params[:location_id]))
    redirect_to :action => 'location', :id => @item
  end

#################################################################

  def status
    #render :layout => false
  end

#################################################################

  def notes
    if request.post?
        @item.log_history(params[:note], current_user.id)
    end
  end

#################################################################

  def auto_complete
    @items = current_inventory_pool.items.search(params[:query])
    render :partial => 'auto_complete'
  end

#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:item_id] if params[:item_id]
    @item = current_inventory_pool.items.find(params[:id]) if params[:id]
    @model = current_inventory_pool.models.find(params[:model_id]) if params[:model_id]
    
    @tab = :item_backend if @item    
  end

end
