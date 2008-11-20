class Admin::UsersController < Admin::AdminController

  before_filter :pre_load

  def index
    case params[:filter]
      when "admins"
        users = User.admins
      when "managers"
        users = User.managers
      when "students"
        users = User.students
      else
        users = User
    end
    
    unless params[:query].blank?
      @users = users.search(params[:query], :page => params[:page], :per_page => $per_page)
    else
      @users = users.paginate :page => params[:page], :per_page => $per_page
    end
  end
  
  def show
  end

  def new
    @user = User.new
    render :action => 'show'
  end

  def create
    @user = User.new
    update
  end

  def update
    if @user.update_attributes(params[:user])
      redirect_to admin_user_path(@user)
    else
      # TODO 12 ** refactor to after_filter, then remove errors from tabnav views
      # flash[:error] = @user.errors.full_messages.to_s # or .join ??

      render :action => 'show' # TODO 24** redirect to the correct tabbed form
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path
  end

#################################################################

  def access_rights
  end
  
  def add_access_right
    r = Role.find(params[:access_right][:role_id])
    ip = InventoryPool.find(params[:access_right][:inventory_pool_id]) unless params[:access_right][:inventory_pool_id].blank? 
    @user.access_rights.create(:role => r, :inventory_pool => ip)

    redirect_to :action => 'access_rights', :id => @user
  end

  def remove_access_right
    @user.access_rights.delete(@user.access_rights.find(params[:access_right_id]))
    redirect_to :action => 'access_rights', :id => @user
  end

#################################################################

  def auto_complete
    @users = User.search(params[:query])
    render :partial => 'auto_complete'
  end

  private
  
  def pre_load
    params[:id] ||= params[:user_id] if params[:user_id]
    @user = User.find(params[:id]) if params[:id]
  end
  
end
