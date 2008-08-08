class Backend::ModelsController < Backend::BackendController
  active_scaffold :model do |config|
    config.columns = [:manufacturer, :name, :model_groups, :locations]
    config.columns.each { |c| c.collapsed = true }

    config.actions.exclude :create, :update, :delete
  end

  # filter for active_scaffold (through locations)
  def conditions_for_collection
    #old# {:inventory_pool_id => current_inventory_pool.id}
    ['locations.inventory_pool_id = ?', current_inventory_pool.id] 
  end

#################################################################

  
  # TODO require_role "admin" ?

  # TODO refactor for active_scaffold ?
#  def index
#    @models = current_user.models
#  end

  def details
    @model = current_inventory_pool.models.find(params[:id])
 
    render :layout => $modal_layout_path
  end


  def available_items
    # OPTIMIZE prevent injection
    items = current_inventory_pool.items.find(:all, :conditions => ["model_id IN (#{params[:model_ids]}) AND inventory_code LIKE ?", '%' + params[:code] + '%'])
    # OPTIMIZE check availability
    @items = items.select {|i| i.in_stock? }
    
    render :inline => "<%= auto_complete_result(@items, :inventory_code) %>"
  end

  
##########################################################

  def upload_image
    @model = current_inventory_pool.models.find(params[:id])

    if request.post?
      @image = Image.new(params[:image])
      @image.model = @model
      if @image.save
        flash[:notice] = 'Attachment was successfully created.'
        redirect_to :action => 'details', :id => @model.id
      end
    end
  end
  
end
