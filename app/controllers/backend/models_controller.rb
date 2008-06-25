class Backend::ModelsController < Backend::BackendController
  # TODO require_role ?

  def index
#    @models = Model.find(:all)
    items = current_user.inventory_pools.collect(&:items).flatten
    @models = items.collect(&:model).uniq  
  end


  def show
    @model = Model.find(params[:id])
 
    render :layout => $modal_layout_path
  end


  def available_items
    # TODO filter only available items
    #old# @items = Model.find(params[:id]).items
    @items = current_inventory_pool.items.find(:all, :conditions => ["model_id = ? AND inventory_code LIKE ?", params[:id], '%' + params[:code] + '%'])

    # TODO check availability
    
    render :inline => "<%= auto_complete_result(@items, :inventory_code) %>"
  end
  
end
