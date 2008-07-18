class Backend::ItemsController < Backend::BackendController
  active_scaffold :item do |config|
    config.columns = [:model, :inventory_pool, :inventory_code, :serial_number, :status_const, :in_stock?]

    config.list.sorting = { :model => :asc }
  end

  # filter for active_scaffold
  def conditions_for_collection
     {:inventory_pool_id => current_inventory_pool.id}
  end

#################################################################

  # TODO remove, refactor for active_scaffold
  def index_old
    @items = current_inventory_pool.items

    if params[:search]
      @items = @items.find_by_contents(params[:search])
    end

    render :layout => false if request.post?  
  end
  
end
