# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # AuthenticatedSystem must be included for RoleRequirement, and is provided by installing acts_as_authenticates and running 'script/generate authenticated account user'.
  include AuthenticatedSystem
  # You can move this into a different controller, if you wish.  This module gives you the require_role helpers, and others.
  include RoleRequirementSystem


  helper :all # include all helpers, all the time

  init_gettext 'leihs'

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'a51355e168a2870e8e42d11f9390b986'
  
  # TODO temp
  $theme = '00-patterns'
  $modal_layout_path = $theme + '/modal'
  $general_layout_path = $theme + '/general'
  $layout_public_path = '/layouts/' + $theme

  layout $general_layout_path

####################################################  

  protected

    def current_user_and_inventory
      [current_user, current_inventory_pool]
    end
    
    # Accesses the current inventory pool from the session.
    # Future calls avoid the database because nil is not equal to false.
    def current_inventory_pool
      @current_inventory_pool ||= InventoryPool.find(session[:inventory_pool_id]) if session[:inventory_pool_id] and not @current_inventory_pool == false
      @current_inventory_pool ||= InventoryPool.first #temp# TODO remove it
    end

    # Store the given inventory pool id in the session.
    def current_inventory_pool=(new_inventory_pool)
      session[:inventory_pool_id] = new_inventory_pool ? new_inventory_pool.id : nil
      @current_inventory_pool = new_inventory_pool || false
    end  

  
end
