class Backend::ModelsController < Backend::BackendController

  before_filter :pre_load

  def index
    models = current_inventory_pool.models

    case params[:filter]
      when "packages"
        models = models.packages
    end
    
    unless params[:query].blank?
      @models = models.find_by_contents("*" + params[:query] + "*", :page => params[:page], :per_page => $per_page)
    else
      @models = models.paginate :page => params[:page], :per_page => $per_page
    end
  end

  def show_package 
  end

  def new_package
    render :action => 'show_package' #, :layout => false
  end

  def update_package(name = params[:name], inventory_code = params[:inventory_code])
    @model.items << Item.new(:location => current_inventory_pool.main_location) if @model.items.empty?
    @model.items.first.inventory_code = inventory_code
    @model.name = name
    @model.save 
    redirect_to :action => 'show_package', :id => @model
  end
  
  def search_package_items
    @items = current_inventory_pool.items.find_by_contents("*" + params[:query] + "*")
    render :partial => 'item_for_package', :collection => @items
  end

  def add_package_item
    @model.items.first.children << current_inventory_pool.items.find(params[:item_id])
    @model.save
    redirect_to :action => 'show_package', :id => @model
  end

  def remove_package_item
    @model.items.first.children.delete(@model.items.first.children.find(params[:item_id]))
    redirect_to :action => 'show_package', :id => @model
  end

#################################################################
  def details 
    render :layout => $modal_layout_path
  end


  def available_items
    # OPTIMIZE prevent injection
    a_items = current_inventory_pool.items.find(:all, :conditions => ["model_id IN (#{params[:model_ids]}) AND inventory_code LIKE ?", '%' + params[:code] + '%'])
    # OPTIMIZE check availability
    @items = a_items.select {|i| i.in_stock? }
    
    render :inline => "<%= auto_complete_result(@items, :inventory_code) %>"
  end

  
#################################################################

  # TODO
  def show
    redirect_to :action => 'show_package', :model_id => @model if @model.is_package?
    # template has to be .rhtml (??)
  end
 
  def search
    # TODO scope Template for the current inventory pool
    @search_result = current_inventory_pool.models.find_by_contents("*" + params[:query] + "*", :multi => [Template]) if request.post?
    render  :layout => $modal_layout_path
  end  
 
#################################################################

  def items
    #render :layout => false
  end

#################################################################

  def properties
    #render :layout => false
  end

#################################################################

  def accessories
    #render :layout => false
  end
  
  def set_accessories(accessory_ids = params[:accessory_ids] || [])
    @current_inventory_pool.accessories -= @model.accessories
    
    accessory_ids.each do |a|
      @current_inventory_pool.accessories << @model.accessories.find(a.to_i)
    end
    redirect_to :action => 'accessories', :id => @model
  end
  
#################################################################

  def compatibles
    #render :layout => false
  end
  
  def search_compatible
    @models = current_inventory_pool.models.find_by_contents("*" + params[:query] + "*")
    render :partial => 'model_for_compatible', :collection => @models
  end

  def add_compatible
    @model.compatibles << current_inventory_pool.models.find(params[:compatible_id])
    redirect_to :action => 'compatibles', :id => @model
  end

  def remove_compatible
    @model.compatibles.delete(@model.compatibles.find(params[:compatible_id]))
    redirect_to :action => 'compatibles', :id => @model
  end

#################################################################

  def images
  end

#################################################################

  private
  
  def pre_load
    params[:model_id] ||= params[:id] if params[:id]
    @model = current_inventory_pool.models.find(params[:model_id]) if params[:model_id]
    @model ||= Model.new # OPTIMIZE
  end

end
