require 'digest/sha1'

class Authenticator::DatabaseAuthenticationController \
  < Authenticator::AuthenticatorController

  def login_form_path
    '/authenticator/db/login'
  end

  def login
    super
    @preferred_language = Language.preferred(request.env['HTTP_ACCEPT_LANGUAGE'])
    if request.post?
      if (l = DatabaseAuthentication.authenticate(params[:login][:username],
                                                  params[:login][:password]))
        self.current_user = l.user
        if current_user.access_rights.active.size == 0
          render text: _("You don't have any rights to access this application.")
          return
        end
        redirect_back_or_default('/')
      else
        flash[:notice] = _('Invalid username/password')
        redirect_to action: 'login'
      end
    end
  end

  def change_password
    if request.post? and params[:db_auth][:password] != '_password_'
      d = DatabaseAuthentication.find_by_user_id(current_user.id)
      if d.update_attributes(params[:db_auth])
        flash[:success] = _('Password changed')
      else
        flash[:error] = d.errors.full_messages.uniq.join(', ')
      end
    end
    redirect_to borrow_current_user_path
  end

end
