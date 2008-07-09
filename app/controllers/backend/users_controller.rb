class Backend::UsersController < Backend::BackendController
  active_scaffold :user do |config|
    config.columns = [:login, :access_rights]
  end

#  def index
#    @users = User.find(:all)    
#  end

  # TODO refactor for active_scaffold  
  def details
    @user = User.find(params[:id])
 
    render :layout => $modal_layout_path
  end

  def search
    if request.post?
      @search_result = User.find_by_contents("*" + params[:search] + "*")
    end
    render  :layout => $modal_layout_path
  end  
  
end
