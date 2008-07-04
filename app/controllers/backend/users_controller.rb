class Backend::UsersController < Backend::BackendController
  #active_scaffold :user

  def index
    @users = User.find(:all)    
  end

  
  def show
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
