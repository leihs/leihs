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
      @users = users.find_by_contents("*" + params[:query] + "*", :page => params[:page], :per_page => $per_page)
    else
      @users = users.paginate :page => params[:page], :per_page => $per_page      
    end
  end

  def show
  end

  def details
    render :action => 'show', :layout => $modal_layout_path
  end

  def search
    @search_result = current_inventory_pool.users.find_by_contents("*" + params[:query] + "*") if request.post?
    render  :layout => $modal_layout_path
  end  

  def remind
    flash[:notice] = "User #{@user} reminded " + @user.remind(current_user)
    redirect_to :action => 'index' 
  end
  
  def new_contract
    redirect_to :controller => 'hand_over', :action => 'show', :user_id => params[:id]
  end

  #################################################################

  private
  
  def pre_load
    params[:id] ||= params[:user_id] if params[:user_id]
    @user = current_inventory_pool.users.find(params[:id]) if params[:id]
  end

end
