require 'digest/sha1'

class Authenticator::DatabaseAuthenticationController < Authenticator::AuthenticatorController

  def login_form_path
    "/authenticator/db/login"
  end
  
  def login
    super
    @preferred_language = Language.preferred(request.env["HTTP_ACCEPT_LANGUAGE"])
    if request.post?
      if (l = DatabaseAuthentication.authenticate(params[:login][:username], params[:login][:password]))
        self.current_user = l.user
        if current_user.access_rights.active.size == 0
          render :text => _("You don't have any rights to access this application.") 
          return
        end
        redirect_back_or_default("/")
      else
        flash[:notice] = _("Invalid username/password")
        redirect_to :action => 'login'
      end
    end
  end

  def change_password
    if request.post?
      d = DatabaseAuthentication.create_with(params[:dbauth]).find_or_create_by(login: params[:dbauth][:login])
      d.update_attributes(params[:dbauth])
      d.password_confirmation = d.password
      unless d.save
        flash[:error] = d.errors.full_messages.uniq
      else
        flash[:notice] = _("Password changed")
      end
      render :update do |page|
        page.replace_html 'flash', flash_content
        flash.discard
      end
    end
    
  end
  
end
  
