class Admin::ItemsController < Admin::AdminController
  
  before_filter :pre_load
  
  def index
    case params[:filter]
      when "incompletes"
        items = Item.incompletes
      else
        items = Item
    end
    
    unless params[:query].blank?
      @items = items.find_by_contents("*" + params[:query] + "*",  :page => params[:page], :per_page => $per_page)
    else
      @items = items.paginate :page => params[:page], :per_page => $per_page 
    end
  end

  def show
    # template has to be .rhtml (??)
  end

  def new
    render :action => 'show'
  end
      
  def update 
    @item ||= Item.create
    @item.inventory_code = params[:inventory_code]
    @item.serial_number = params[:serial_number]
    @item.step = :step_item
    @item.save
    render :action => 'show'
  end

#################################################################

  def model
    #render :layout => false
  end

  def search_model
    @models = Model.find_by_contents("*" + params[:query] + "*", :limit => 999) # OPTIMIZE limit
    render :partial => 'model_for_item', :collection => @models
  end

  def set_model
    @item.model = Model.find(params[:model_id])
    @item.step = :step_model
    @item.save
    redirect_to :action => 'model', :id => @item
  end

#################################################################

  def inventory_pool
    #render :layout => false
  end
  
  def set_inventory_pool
    ip = InventoryPool.find(params[:inventory_pool_id])
    @item.location = ip.main_location
    
    # if is the first item of that model assigned to the inventory_pool,
    # then creates accessory associations
    @item.model.accessories.each {|a| ip.accessories << a } unless ip.models.include?(@item.model)
    # TODO *17* fix problem with accessories setting inventory_pool
    
    
    @item.step = :step_location
    @item.save
    redirect_to :action => 'inventory_pool', :id => @item
  end

#################################################################

  def status
    #render :layout => false
  end

#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:item_id] if params[:item_id]
    @item = Item.find(params[:id]) if params[:id]
    @item ||= Item.new
  end

end
