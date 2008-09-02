class Admin::ItemsController < Admin::AdminController
  
  before_filter :pre_load
  
  active_scaffold :item do |config|
    config.columns = [:model, :inventory_pool, :location, :inventory_code, :serial_number, :status_const, :in_stock?]
    config.columns.each { |c| c.collapsed = true }

    config.show.link.inline = false

    config.list.sorting = { :model => :asc }
  end

#################################################################

  def incompletes
    render :inline => "Incompletes <hr /> <%= render :active_scaffold => 'admin/items', :conditions => ['items.id IN (?)', Item.incompletes] %>", # TODO optimize conditions
           :layout => $general_layout_path
  end

#################################################################

  # TODO
  def show
    # template has to be .rhtml (??)
  end

  # TODO steps: [model, inventory_pool, inventory_code]
  def new
    render :action => 'show' #, :layout => false
  end
    
  # TODO
  def edit 
    render :action => 'show' #, :layout => false
  end
  
  # TODO
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
    @models = Model.find_by_contents("*" + params[:search] + "*", :limit => 999) # OPTIMIZE limit
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
