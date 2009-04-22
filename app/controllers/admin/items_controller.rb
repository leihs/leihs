class Admin::ItemsController < Admin::AdminController
  
  before_filter :pre_load
  
  def index
    params[:sort] ||= 'model_name'
    params[:dir] ||= 'asc'

    if @inventory_pool
      items = @inventory_pool.items
    elsif @model
      items = @model.items
    else
      items = Item
    end    

    case params[:filter]
      when "broken"
        items = items.broken
      when "incomplete"
        items = items.incomplete
      when "unborrowable"
        items = items.unborrowable
      when "unfinished"
        items = items.unfinished
    end
        
    @items = items.search(params[:query], :page => params[:page], :order => params[:sort].to_sym, :sort_mode => params[:dir].to_sym, :include => [:model, :location])
  end

  def show
    @item.step = 'step_item'
  end

  def new
    @item = Item.new(:model => @model)
    show and render :action => 'show'
  end

  def create
    @item = Item.new(:model => @model)
    update
  end
      
  def update
    @item.step = params[:item][:step]
    if @item.update_attributes(params[:item])
      redirect_to admin_model_item_path(@item.model, @item)
    else
      flash[:error] = @item.errors.full_messages
      show and render :action => 'show' # TODO 24** redirect to the correct tabbed form
      #redirect_to request.referer # TODO 24** keep form fields
    end
  end

  def destroy
    @item.destroy
    redirect_to admin_items_path
  end

#################################################################

  def model
    #old# @item.step = 'step_model'
  end

#################################################################

  def inventory_pool
    if request.post?
      ip = InventoryPool.find(params[:inventory_pool_id])
      @item.location = ip.main_location
      
      # if it's the first item of that model assigned to the inventory_pool,
      # then creates accessory associations
      @item.model.accessories.each {|a| ip.accessories << a unless ip.accessories.include?(a) } unless ip.models.include?(@item.model)
      
      @item.step = 'step_location'
      @item.save
      redirect_to
    end
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
    params[:item_id] ||= params[:id] if params[:id]
    @inventory_pool = InventoryPool.find(params[:inventory_pool_id]) if params[:inventory_pool_id]
    @model = Model.find(params[:model_id]) if params[:model_id]
    @item = Item.find(params[:item_id]) if params[:item_id]

    @tabs = []
    @tabs << :inventory_pool_admin if @inventory_pool
    @tabs << :model_admin if @model
    @tabs << :item_admin if @item
  end

end
