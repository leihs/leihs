class Backend::ItemsController < Backend::BackendController
  
  before_filter :pre_load
  
  active_scaffold :item do |config|
    config.columns = [:model, :inventory_pool, :location, :inventory_code, :serial_number, :status_const, :in_stock?]
    config.columns.each { |c| c.collapsed = true }

    config.show.link.inline = false

    config.list.sorting = { :model => :asc }
    config.action_links.add 'toggle_status', :label => 'Toggle borrowable status', :type => :record # TODO optimize
  end

  # filter for active_scaffold through location
  def conditions_for_collection
    # TODO return nil if current_user role is 'Admin'
    #old# {:inventory_pool_id => current_inventory_pool.id}
    ['locations.inventory_pool_id = ?', current_inventory_pool.id] 
  end

#################################################################

  def in_repair
    render :inline => "<%= render :active_scaffold => 'backend/items', :constraints => { :status_const => Item::UNBORROWABLE } %>",
           :layout => $general_layout_path
  end

  def details
    render :layout => $modal_layout_path
  end

#################################################################

  # TODO
  def show
    # template has to be .rhtml (??)
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

  # TODO remove, refactor for active_scaffold
  def index_old
    @items = current_inventory_pool.items

    if params[:search]
      @items = @items.find_by_contents(params[:search])
    end

    render :layout => false if request.post?  
  end

#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:item_id] if params[:item_id]
    @item = current_inventory_pool.items.find(params[:id]) if params[:id]
  end

end
