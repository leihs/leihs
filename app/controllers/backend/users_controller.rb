class Backend::UsersController < Backend::BackendController

  def index
    @users = User.find(:all)    
  end

  
  def show
    @user = User.find(params[:id])
 
    render :layout => $modal_layout_path
  end
  
end
