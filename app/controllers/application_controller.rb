# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  #rails3# TODO upgrade restful-authentication or use devise authentication system instead ??
  require File.join(Rails.root, 'lib', 'authenticated_system.rb')
  include AuthenticatedSystem

  before_filter :set_gettext_locale

  protect_from_forgery # See ActionController::RequestForgeryProtection for details

####################################################  
  
  def index
    @preferred_language = Language.preferred(request.env["HTTP_ACCEPT_LANGUAGE"])
    
    #check if user is logged in then depending on rights (manager or only customer) redirect to frontend or backend otherwise go on showing splash screen
    if logged_in?
      if current_user.has_role?('manager', nil, false) or current_user.has_role?('admin')
        redirect_to backend_path, flash: flash
      else
        redirect_to categories_path, flash: flash
      end
    end
  end
 
####################################################  

  protected

  helper_method :current_inventory_pool
  
  # TODO **20 optimize lib/role_requirement and refactor to backend  
  def current_inventory_pool
    nil
  end

  def add_visitor(user)
    session[:last_visitors] ||= []
    session[:last_visitors].delete([user.id, user.name])
    session[:last_visitors].delete_at(0) if session[:last_visitors].size > 4 
    session[:last_visitors] << [user.id, user.name]
  end

  def set_gettext_locale
    if current_user
      if current_user.language.nil?
        current_user.language = Language.default_language
        current_user.save
      end
      
      if params[:locale]
        language = Language.where(:locale_name => params[:locale]).first
        language ||= Language.default_language
        current_user.language = language # language is a protected attribute, it can't be mass-asigned via update_attributes
        current_user.save
        current_user.reload
      end
      locale_symbol = current_user.language.locale_name.to_sym
    else
      locale_symbol = Language.default_language.locale_name.to_sym
    end
    
    I18n.locale = locale_symbol
  end

end
