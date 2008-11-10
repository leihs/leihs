class Backend::ItemsController < Backend::BackendController
  
  before_filter :pre_load

  def index

    if @model
      items = @model.items & current_inventory_pool.items # TODO 28** optimize intersection
    else
      items = current_inventory_pool.items
    end    

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

  def show
    # TODO 22** render :layout => $modal_layout_path if <greybox>
  end

#################################################################

# TODO 30** remove, also view
#old#
#  def model
#    #render :layout => false
#  end

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

  def auto_complete
    @items = current_inventory_pool.items.find_by_contents("*" + params[:query] + "*")
    render :partial => 'auto_complete'
  end

#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:item_id] if params[:item_id]
    @item = current_inventory_pool.items.find(params[:id]) if params[:id]
    @model = current_inventory_pool.models.find(params[:model_id]) if params[:model_id]
  end

end
