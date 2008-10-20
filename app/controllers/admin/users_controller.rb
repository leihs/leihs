class Admin::UsersController < Admin::AdminController

  before_filter :pre_load

  def index
    
    unless params[:query].blank?
      users = User.find_by_contents("*" + params[:query] + "*", :page => params[:page], :per_page => $per_page)
    end

    # TODO *18* optimize
    users ||= User.all

    # TODO *17* search and filter
    case params[:filter]
      when "admins"
        users = users & User.admins # TODO optimize conditions
      when "managers"
        users = users & User.managers # TODO optimize conditions
      when "students"
        users = users & User.students # TODO optimize conditions
    end

    # TODO *17* you're paginating twice!!!
    @users = users.paginate :page => params[:page], :per_page => $per_page      
  end
  
  def show
    @user = User.find(params[:id])
  end

#################################################################

  def access_rights
  end
  
  def add_access_right
    r = Role.find(params[:access_right][:role_id])
    ip = InventoryPool.find(params[:access_right][:inventory_pool_id])
    @user.access_rights << AccessRight.new(:role => r, :inventory_pool => ip)

    redirect_to :action => 'access_rights', :id => @user
  end

  def edit_access_right
    # TODO *18* implement
  end

  def remove_access_right
    @user.access_rights.delete(@user.access_rights.find(params[:access_right_id]))
    redirect_to :action => 'access_rights', :id => @user
  end

#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:user_id] if params[:user_id]
    @user = User.find(params[:id]) if params[:id]
  end
  
end
