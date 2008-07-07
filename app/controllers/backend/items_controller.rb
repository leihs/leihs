class Backend::ItemsController < Backend::BackendController
  active_scaffold :item

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
