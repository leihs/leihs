class Backend::ItemsController < Backend::BackendController
  
  before_filter :pre_load

  def index
    items = current_inventory_pool.items

    case params[:filter]
      when "in_repair"
        items = items.in_repair
    end
    
    unless params[:query].blank?
      @items = items.find_by_contents("*" + params[:query] + "*", :page => params[:page], :per_page => $per_page)
    else
      @items = items.paginate :page => params[:page], :per_page => $per_page      
    end
  end

  # TODO
  def show
    # template has to be .rhtml (??)
  end

  def details
    render :layout => $modal_layout_path
  end

#################################################################

  def model
    #render :layout => false
  end

#################################################################

  def location
    #render :layout => false
  end
  
  def set_location
    @item.location = current_inventory_pool.locations.find(params[:location_id])
    @item.save
    redirect_to :action => 'location', :id => @item
  end

#################################################################

  def status
    #render :layout => false
  end

  def toggle_status
    @item.status_const = (@item.status_const == Item::BORROWABLE ? Item::UNBORROWABLE : Item::BORROWABLE)
    @item.save
    redirect_to :action => 'status', :id => @item
  end

#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:item_id] if params[:item_id]
    @item = current_inventory_pool.items.find(params[:id]) if params[:id]
  end

end
