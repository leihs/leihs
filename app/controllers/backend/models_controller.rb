class Backend::ModelsController < Backend::BackendController

  def index
#    @models = Model.find(:all)
    items = current_user.inventory_pools.collect(&:items).flatten
    @models = items.collect(&:model).uniq  
  end


  def show
    @model = Model.find(params[:id])
 
    render :layout => $modal_layout_path
  end
  
end
