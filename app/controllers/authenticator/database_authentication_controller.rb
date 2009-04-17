require 'digest/sha1'

class Authenticator::DatabaseAuthenticationController < Authenticator::AuthenticatorController

  $general_layout_path = 'layouts/backend/' + $theme + '/general'
     
  layout $general_layout_path
        
  def login_form_path
    "/authenticator/db/login"
  end
  
  def login
    if request.post?
      l = DatabaseAuthentication.authenticate(params[:login][:user], params[:login][:password])
      self.current_user = l.user
      redirect_back_or_default("/")
    end
  end

  def change_password
    if request.post?
      d = DatabaseAuthentication.find_or_create_by_login(params[:dbauth])
      d.update_attributes(params[:dbauth])
      d.password_confirmation = d.password
      unless d.save
        flash[:error] = d.errors.full_messages
      end
      redirect_to :controller => 'admin/users', :action => 'show', :id => d.user.id
    end
  end
  
end
  
