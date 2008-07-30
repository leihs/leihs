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
    @user = current_inventory_pool.users.find(params[:id])
    render :layout => $modal_layout_path
  end

  def search
    @search_result = User.find_by_contents("*" + params[:search] + "*") if request.post?
    render  :layout => $modal_layout_path
  end  

  def remind
    @user = current_inventory_pool.users.find(params[:user_id])
    render :text => @user.remind(current_user) # TODO    
  end
  
end
