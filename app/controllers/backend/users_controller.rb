class Backend::UsersController < Backend::BackendController

  def index
    @users = User.find(:all)    
  end

  
  def show
    if params[:id]
      @user = User.find(params[:id])
    else
      @user = current_user
    end
 
    render :layout => $modal_layout_path  if request.post?
  end
  
end
