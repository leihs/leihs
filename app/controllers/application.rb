# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # AuthenticatedSystem must be included for RoleRequirement, and is provided by installing acts_as_authenticates and running 'script/generate authenticated account user'.
  include AuthenticatedSystem
  # You can move this into a different controller, if you wish.  This module gives you the require_role helpers, and others.
  include RoleRequirementSystem

  helper :all # include all helpers, all the time

  # TODO 16** http://www.yotabanana.com/hiki/ruby-gettext-howto-rails.html
  before_init_gettext :define_locale
  def define_locale
    if params[:locale] #if (cookies["lang"].nil? or cookies["lang"].empty?)
      set_locale params[:locale]
#    else
#      set_locale "en"
    end
  end 
  init_gettext 'leihs'

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'a51355e168a2870e8e42d11f9390b986'
  
  # TODO temp
  $theme = '00-patterns'
  $modal_layout_path = 'layouts/' + $theme + '/modal'
  $general_layout_path = 'layouts/' + $theme + '/general'
  $layout_public_path = '/layouts/' + $theme

  $per_page = 10 # OPTIMIZE keep per_page in user session?
  
  layout $general_layout_path
  
####################################################  

  protected
    
  # TODO **20 optimize lib/role_requirement and refactor to backend  
  def current_inventory_pool
    nil
  end

  # overriding
  # TODO 16** doesn't work for *_url and *_path 
  def default_url_options(options = nil)
    { :layout => params[:layout] }
  end

  
end
