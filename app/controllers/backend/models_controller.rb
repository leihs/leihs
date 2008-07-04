class Backend::ModelsController < Backend::BackendController
  active_scaffold :model
  
  # TODO require_role "admin" ?

  def index
    @models = current_user.inventory_pools.collect(&:models).flatten.uniq
  end


  def show
    @model = Model.find(params[:id])
 
    render :layout => $modal_layout_path
  end


  def available_items
    # OPTIMIZE prevent injection
    items = current_inventory_pool.items.find(:all, :conditions => ["model_id IN (#{params[:model_ids]}) AND inventory_code LIKE ?", '%' + params[:code] + '%'])
    # OPTIMIZE check availability
    @items = items.select {|i| i.in_stock? }
    
    render :inline => "<%= auto_complete_result(@items, :inventory_code) %>"
  end
  
end
