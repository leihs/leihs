class Backend::ItemsController < Backend::BackendController
  active_scaffold :item do |config|
    config.columns = [:model, :inventory_pool, :inventory_code, :serial_number, :status]

    config.list.sorting = { :model => :asc }
  end
  
  # TODO remove, refactor for active_scaffold
  def index_old
    @items = current_inventory_pool.items

    if params[:search]
      @items = @items.find_by_contents(params[:search])
    end

    if request.post?
      render :action => 'index', :layout => false
    else
      render :action => 'index'
    end  
  end
  
end
