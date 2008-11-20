class Backend::UsersController < Backend::BackendController

  before_filter :pre_load

  def index
    case params[:filter]
      when "managers"
        users = current_inventory_pool.managers
      when "students"
        users = current_inventory_pool.students
      else
        users = current_inventory_pool.users
    end

    unless params[:query].blank?
      @users = users.search(params[:query], :page => params[:page], :per_page => $per_page)
    else
      @users = users.paginate :page => params[:page], :per_page => $per_page      
    end
    
    render :layout => $modal_layout_path if params[:layout] == "modal"
  end

  def show
    render :layout => $modal_layout_path if params[:layout] == "modal"
  end

  def remind
    flash[:notice] = "User #{@user} has been reminded " + @user.remind(current_user)
    redirect_to :action => 'index' 
  end
  
  def new_contract
    redirect_to [:backend, @current_inventory_pool, @user, :hand_over]
  end

  #################################################################

  private
  
  def pre_load
    params[:id] ||= params[:user_id] if params[:user_id]
    @user = current_inventory_pool.users.find(params[:id]) if params[:id]
  end

end
