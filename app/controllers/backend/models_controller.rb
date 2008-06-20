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

  def search
    if request.post?
      @search_result = Model.find_by_contents("*" + params[:text] + "*")
    end

    @categories = Category.roots # TODO refactor?
    
    render  :layout => $modal_layout_path
  end  
  
  # TODO refactor?
  def expand_category
    @categories = Category.find(params[:id]).children if params[:id]
    render :partial => 'categories'
  end


  def available_items
    # TODO filter only available items
    #old# @items = Model.find(params[:id]).items
    @items = current_inventory_pool.items.find(:all, :conditions => ["model_id = ? AND inventory_code LIKE ?", params[:id], '%' + params[:code] + '%'])

    # TODO check availability
    
    render :inline => "<%= auto_complete_result(@items, :inventory_code) %>"
  end
  
end
