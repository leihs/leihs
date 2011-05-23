# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  #rails3# TODO upgrade restful-authentication or use devise authentication system instead ??
  # AuthenticatedSystem must be included for RoleRequirement, and is provided by installing acts_as_authenticates and running 'script/generate authenticated account user'.
  require File.join(Rails.root, 'lib', 'authenticated_system.rb')
  include AuthenticatedSystem
  # You can move this into a different controller, if you wish. This module gives you the require_role helpers, and others.
  require File.join(Rails.root, 'lib', 'role_requirement_system.rb')
  include RoleRequirementSystem

#rails3#
## http://www.yotabanana.com/hiki/ruby-gettext-howto-rails.html
## http://www.yotabanana.com/hiki/ruby-gettext-rails-migration.html
# before_init_gettext :define_locale
#
# def define_locale
# if params[:locale]
# set_locale params[:locale]
# params[:lang] = params[:locale] # Bug? Gettext seems not to set the language properly unless this is set
# current_user.update_attributes(:language_id => Language.first(:conditions => {:locale_name => params[:locale]})) if logged_in?
# else
# locale = logged_in? ? current_user.language.locale_name : Language.default_language.locale_name
# set_locale locale
# params[:lang] = locale # Bug? Gettext seems not to set the language properly unless this is set
# end
# end
# init_gettext 'leihs'
  before_filter :set_gettext_locale

  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  $theme = '00-patterns'
  $layout_public_path = '/layouts/' + $theme

  $per_page = 50 # OPTIMIZE keep per_page in user session?
 
####################################################  

  protected

  helper_method :current_inventory_pool
  
  # TODO **20 optimize lib/role_requirement and refactor to backend  
  def current_inventory_pool
    nil
  end

  def add_visitor(user)
    session[:last_visitors] ||= []
    unless session[:last_visitors].include?([user.id, user.name])
      session[:last_visitors].delete_at(0) if session[:last_visitors].size > 5 
      session[:last_visitors] << [user.id, user.name]
    end
  end

end
