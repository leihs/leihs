require 'persona'

class SessionsController < ApplicationController

  AUTHENTICATION_URL = 'http://localhost:3000/backend/temporary/login'

  # render new.rhtml
  def new
    if Rails.env.development? and params["bypass"] and User.find_by_login(params["bypass"])
      create params["bypass"]
    else
      redirect_to :action => 'authenticate'
    end
  end

  # TODO 05** temporary
  def old_new
    render :action => 'new', :layout => 'layouts/backend/general'
  end

  def authenticate(id = params[:id])
    @selected_system = AuthenticationSystem.active_systems.find(id) if id
    @selected_system ||= AuthenticationSystem.default_system.first
    sys = eval("Authenticator::" + @selected_system.class_name + "Controller").new
    redirect_to sys.login_form_path
  rescue
    logger.error($!)
    raise "No default authentication system selected." unless AuthenticationSystem.default_system.first
    raise "No system selected." unless @selected_system
    raise 'Class not found or missing login_form_path method: ' + @selected_system.class_name
  end

#TODO 1009: Remove as soon as not needed anymore
  def switch_to_ldap
    AuthenticationSystem.update_all({:is_active => false, :is_default => false})
    a=AuthenticationSystem.find_by_class_name "LdapAuthentication"
    a.class_name="LdapAuthentication"
    a.is_default = true
    a.is_active =true
    a.save
    flash[:notice] = "Switched Authentication to LDAP"
    redirect_back_or_default("/")
  end

  # TODO 05** temporary, needed by Rspec tests
  def create(login = params[:login])
    self.current_user = User.find_by_login(login)
    if logged_in?
      if current_user.access_rights.size == 0
        render :text => _("You don't have any rights to access this application.") 
        return
      end
      redirect_back_or_default('/')
      flash[:notice] = _("Logged in successfully")
    else
      render :action => 'new'
    end
  end

  def destroy
    # store last inventory pool to the settings column
    if current_user
      current_user.latest_inventory_pool_id_before_logout = session[:current_inventory_pool_id]
      current_user.save
    end
    # delete cookie and reset session
    cookies.delete :auth_token
    reset_session
    # redirect and flash
    flash[:notice] = _("You have been logged out.")
    redirect_back_or_default('/')
  end
end
