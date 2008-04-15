class Backend::UsersController < Backend::BackendController
  
  def show
    @user = User.find(params[:id])
 
    render :layout => $modal_layout_path
  end
  
end
