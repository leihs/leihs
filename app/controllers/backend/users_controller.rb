class Backend::UsersController < Backend::BackendController

  before_filter :pre_load

  def index
    case params[:filter]
      when "managers"
        users = current_inventory_pool.managers
      when "students"
        users = current_inventory_pool.students
      when "unknown"
        users = User.all - current_inventory_pool.users
      else
        users = current_inventory_pool.users
    end

    @users = users.search(params[:query], :page => params[:page], :per_page => $per_page)
  end

  def show
  end

  def remind
    flash[:notice] = _("User %s has been reminded ") % @user.remind(current_user)
    redirect_to :action => 'index' 
  end
  
  def new_contract
    redirect_to [:backend, @current_inventory_pool, @user, :hand_over]
  end

#################################################################

  def access_rights
  end
  
  def add_access_right
    r = Role.find(params[:access_right][:role_id])
    ar = @user.access_rights.create(:role => r, :inventory_pool => current_inventory_pool, :level => params[:level])
    unless ar.changed?
      flash[:notice] = _("Access Right successfully created")
    else
      flash[:error] = ar.errors.full_messages
    end
    redirect_to :action => 'access_rights', :id => @user
  end

  def remove_access_right
    @user.access_rights.delete(@user.access_rights.find(params[:access_right_id]))
    redirect_to :action => 'access_rights', :id => @user
  end

#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:user_id] if params[:user_id]
#    @user = current_inventory_pool.users.find(params[:id]) if params[:id]
    @user = User.find(params[:id]) if params[:id]

    @tabs = []
    @tabs << :user_backend if @user
  end

end
