# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # AuthenticatedSystem must be included for RoleRequirement, and is provided by installing acts_as_authenticates and running 'script/generate authenticated account user'.
  include AuthenticatedSystem
  # You can move this into a different controller, if you wish.  This module gives you the require_role helpers, and others.
  include RoleRequirementSystem

  helper :all # include all helpers, all the time

# http://www.yotabanana.com/hiki/ruby-gettext-howto-rails.html
# http://www.yotabanana.com/hiki/ruby-gettext-rails-migration.html
  before_init_gettext :define_locale

  def define_locale
    if params[:locale] 
      set_locale params[:locale] 
      current_user.update_attributes(:language_id => Language.first(:conditions => {:locale_name => params[:locale]})) if logged_in?
    else
      locale = logged_in? ? current_user.language.locale_name : Language.default_language.locale_name
      set_locale locale
    end
  end 
  init_gettext 'leihs'

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'a51355e168a2870e8e42d11f9390b986'
  
  $theme = '00-patterns'
  $layout_public_path = '/layouts/' + $theme

  $per_page = 50 #old# 15 # OPTIMIZE keep per_page in user session?
  
 

 
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

  # TODO 2012 remove this method, find different solution without overriding framework methods
  # overriding
  # TODO 16** doesn't work for *_url and *_path 
#  def default_url_options(options = nil)
#    { :layout => params[:layout] }
#  end

  # TODO 2012 remove this method, find different solution without overriding framework methods
  # overriding
  def render(options = nil, extra_options = {}, &block)
    if request.xml_http_request? and options != :update
      options ||= {}
      options[:layout] = false
    end
    super
  end

  # TODO 0501 remove
  def sanitize_order(*values)
    statement = "%s %s"
    statement % values.collect { |value| User.connection.quote_string(value.to_s) }
  end
  
end
