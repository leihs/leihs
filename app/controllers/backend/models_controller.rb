class Backend::ModelsController < Backend::BackendController

  before_filter :pre_load

  active_scaffold :model do |config|
    config.columns = [:manufacturer, :name, :model_groups, :locations, :compatibles]
    config.columns.each { |c| c.collapsed = true }

    config.show.link.inline = false

#    config.actions.exclude :create, :update, :delete
  end

  # filter for active_scaffold (through locations)
  def conditions_for_collection
    #old# {:inventory_pool_id => current_inventory_pool.id}
    ['locations.inventory_pool_id = ?', current_inventory_pool.id] 
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
    # template has to be .rhtml (??)
  end
 
 
#################################################################

  def items
    #render :layout => false
  end

#################################################################

  def properties
    #render :layout => false
  end
  
  def add_property
    @model.properties << Property.create(:key => params[:key], :value => params[:value])
    redirect_to :action => 'properties', :id => @model
  end

  def remove_property
    @model.properties.delete(@model.properties.find(params[:property_id]))
    redirect_to :action => 'properties', :id => @model
  end
  
  def edit_property
    # TODO
  end

#################################################################

  def accessories
    #render :layout => false
  end
  
  def add_accessory
    @model.accessories << Accessory.create(:name => params[:name])
    redirect_to :action => 'accessories', :id => @model
  end

  def remove_accessory
    @model.accessories.delete(@model.accessories.find(params[:accessory_id]))
    redirect_to :action => 'accessories', :id => @model
  end
  
#################################################################

  def compatibles
    #render :layout => false
  end
  
  def search_compatible
    @models = current_inventory_pool.models.find_by_contents("*" + params[:search] + "*")
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
    if request.post?
      @image = Image.new(params[:image])
      @image.model = @model
      if @image.save
        flash[:notice] = 'Attachment was successfully created.'
      else
        flash[:notice] = 'Upload error.'
      end
    end
  end

#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:model_id] if params[:model_id]
    @model = current_inventory_pool.models.find(params[:id]) if params[:id]
  end

end
