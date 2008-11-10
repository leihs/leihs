class SessionsController < ApplicationController

  AUTHENTICATION_URL = 'http://localhost:3000/backend/temporary/login'

  # render new.rhtml
  def new
    redirect_to :action => 'authenticate'
  end

  # TODO 05** temporary
  def old_new
    render :action => 'new', :layout => 'layouts/backend/00-patterns/general'
  end

  def authenticate(id = params[:id])
    @selected_system = AuthenticationSystem.active_systems.find(id) if id
    @selected_system ||= AuthenticationSystem.default_system.first
    
    sys = eval("Authenticator::" + @selected_system.class_name + "Controller").new
    
    redirect_to sys.login_form_path
    
  rescue
    render :text => "No default authentication system selected." unless AuthenticationSystem.default_system.first
    render :text => 'Class not found: ' + @selected_system.class_name
  end

  def create
    self.current_user = User.find_by_login(params[:login])
    if logged_in?
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      render :action => 'new'
    end
  end

  def destroy
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
end
