class Backend::UsersController < Backend::BackendController
  active_scaffold :user do |config|
    config.columns = [:login, :access_rights, :orders, :contracts]
  end

# TODO filter for inventory_pool
  # filter for active_scaffold
#  def conditions_for_collection
#     {:inventory_pool_id => current_inventory_pool.id}
#  end

#################################################################

#  def index
#    @users = User.find(:all)    
#  end

  def details
    @user = User.find(params[:id]) # TODO scope current_inventory_pool
 
    render :layout => $modal_layout_path
  end

  def search
    if request.post?
      @search_result = User.find_by_contents("*" + params[:search] + "*")
    end
    render  :layout => $modal_layout_path
  end  
  
end
