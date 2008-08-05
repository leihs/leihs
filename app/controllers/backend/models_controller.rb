class Backend::ModelsController < Backend::BackendController
  active_scaffold :model do |config|
    config.columns = [:manufacturer, :name, :model_groups]
  end

# TODO filter for inventory_pool
  # filter for active_scaffold
#  def conditions_for_collection
#     {:inventory_pool_id => current_inventory_pool.id}
#  end

#################################################################

  
  # TODO require_role "admin" ?

  # TODO refactor for active_scaffold ?
#  def index
#    @models = current_user.models #old# current_user.inventory_pools.collect(&:models).flatten.uniq
#  end

  def details
    @model = Model.find(params[:id]) # TODO scope current_inventory_pool
 
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
    @model = Model.find(params[:id]) # TODO scope current_inventory_pool

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
