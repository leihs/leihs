class Admin::UsersController < Admin::AdminController

  before_filter :pre_load

  def index
    params[:sort] ||= 'login'
    params[:dir] ||= 'ASC'

    case params[:filter]
      when "admins"
        users = User.admins
      when "managers"
        users = User.managers
      when "customers"
        users = User.customers
      else
        users = User
    end
    
    @users = users.search(params[:query], {:page => params[:page], :per_page => $per_page}, {:order => sanitize_order(params[:sort], params[:dir])})
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
      flash[:error] = @user.errors.full_messages

      #redirect_to request.referer #or# request.env['HTTP_REFERER']
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
    r = Role.find(params[:access_right][:role_id]) if params[:access_right] and not params[:access_right][:role_id].blank?
    r ||= Role.last
    
    if params[:access_right] and not params[:access_right][:inventory_pool_id].blank? 
      ip = InventoryPool.find(params[:access_right][:inventory_pool_id]) 
      ar = @user.access_rights.create(:role => r, :inventory_pool => ip, :level => params[:level])
      unless ar.changed?
        flash[:notice] = _("Access Right successfully created")
      else
        flash[:error] = ar.errors.full_messages
      end
    else
      flash[:error] = _("Inventorypool must be selected.")
    end
    redirect_to :action => 'access_rights', :id => @user
  end

  def remove_access_right
    @user.access_rights.delete(@user.access_rights.find(params[:access_right_id]))
    flash[:notice] = _("Access Right successfully removed")
    redirect_to :action => 'access_rights', :id => @user
  end

#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:user_id] if params[:user_id]
    @user = User.find(params[:id]) if params[:id]

    @tabs = []
    @tabs << :user_admin if @user
  end
  
end
