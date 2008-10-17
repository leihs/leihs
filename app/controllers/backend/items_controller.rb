class Backend::ItemsController < Backend::BackendController
  
  before_filter :pre_load

#old#  
#  active_scaffold :item do |config|
#    config.columns = [:model, :inventory_pool, :location, :inventory_code, :serial_number, :status_const, :in_stock?]
#    config.columns.each { |c| c.collapsed = true }
#
#    config.show.link.inline = false
#
#    config.list.sorting = { :model => :asc }
#    config.action_links.add 'toggle_status', :label => 'Toggle borrowable status', :type => :record # TODO optimize
#
#    config.actions.exclude :create, :update, :delete
#  end
#
#  # filter for active_scaffold through location
#  def conditions_for_collection
#    ['locations.inventory_pool_id = ?', current_inventory_pool.id] 
#  end
#
#  def in_repair
#    render :inline => "<%= render :active_scaffold => 'backend/items', :constraints => { :status_const => Item::UNBORROWABLE } %>",
#           :layout => $general_layout_path
#  end

#################################################################

  def index
    items = current_inventory_pool.items
    
    unless params[:query].blank?
      @items = items.find_by_contents("*" + params[:query] + "*", :page => params[:page], :per_page => Item.per_page)
    else
      case params[:filter]
        when "in_repair"
          items = items.all(:conditions => { :status_const => Item::UNBORROWABLE })
      end
          
      @items = items.paginate :page => params[:page], :per_page => Item.per_page      
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
