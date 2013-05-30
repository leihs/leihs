module Backend::BackendHelper
  
  def last_visitors
    #TODO: last visitors should be scoped through inventory_pool and later through selected day in daily view
    #TODO: move this inside of the inventory pools model ?
    return false if session[:last_visitors].blank?
    session[:last_visitors].reverse.map { |x| link_to x.second, backend_inventory_pool_search_path(current_inventory_pool, :term => x.second), :class => "clickable" }.join()
  end
  
  def is_current_page?(section)
    
    def path_parameters?(h)
      r = request.env["action_dispatch.request.path_parameters"]
      h.all? do |k,v|
        r[k.to_sym] == v.to_s
      end
    end

    #TODO: PREVENT LOOPING
    # return false if caller == is_current_page?(section)
    @cached_is_current_page ||= {}
    @cached_is_current_page[section] ||= case section
      when "lending"
        is_current_page?("daily") or
        is_current_page?("orders") or
        is_current_page?("hand_over") or
        is_current_page?("take_back") or
        is_current_page?("contracts") or
        is_current_page?("visits")
      when "daily"
        current_inventory_pool and path_parameters?(:controller => "backend/inventory_pools", :action => "show")
      when "orders"
        path_parameters?(:controller => "backend/orders") ||
        !!(request.path =~ /acknowledge\/\d+$/)
      when "search"
        path_parameters?(:controller => "backend/backend", :action => :search)
      when "focused_search"
        path_parameters?(:controller => "backend/backend", :action => :search) and params[:types] and params[:types].size == 1
      when "hand_over"
        path_parameters?(:controller => "backend/hand_over", :action => :show)
      when "take_back"
        path_parameters?(:controller => "backend/take_back", :action => :show)
      when "contracts"
        path_parameters?(:controller => "backend/contracts")
      when "visits"
        path_parameters?(:controller => "backend/visits") or
          is_current_page?("hand_over") or
            is_current_page?("take_back")
      when "admin"
        is_current_page?("users") or
        is_current_page?("edit_inventory_pool") or
        is_current_page?("groups") or
        is_current_page?("inventory_pools") or
        is_current_page?("inventory_pool")
      when "inventory_pools"
        is_current_page?("new_inventory_pool") or
        path_parameters?(:controller => "backend/inventory_pools", :action => :index)
      when "new_inventory_pool"
        path_parameters?(:controller => "backend/inventory_pools", :action => :new) or
        path_parameters?(:controller => "backend/inventory_pools", :action => :create)
      when "edit_inventory_pool"
        path_parameters?(:controller => "backend/inventory_pools", :action => :edit) or
        path_parameters?(:controller => "backend/inventory_pools", :action => :update)
      when "inventory"
        is_current_page?("models") or
          is_current_page?("inventory_list") or
          is_current_page?("items") or 
          is_current_page?("inventory_helper") or
          is_current_page?("options") or
          is_current_page?("categories")
      when "inventory_helper"
        path_parameters?(:controller => "backend/inventory_helper")
      when "models"
        path_parameters?(:controller => "backend/models")
      when "inventory_list"
        path_parameters?(:controller => "backend/inventory")
      when "items"
        path_parameters?(:controller => "backend/items", :action => :show) or
        path_parameters?(:controller => "backend/items", :action => :update) or
        path_parameters?(:controller => "backend/items", :action => :new)
      when "users"
        path_parameters?(:controller => "backend/users", :action => :index) or
        path_parameters?(:controller => "backend/users", :action => :edit)
      when "current_user"
        path_parameters?(:controller => "backend/users", :action => :show) and @user == current_user
      when "start_screen"
        current_user.start_screen == request.fullpath
      when "statistics"
        path_parameters?(:controller => "statistics")
      when "options"
        path_parameters?(:controller => "backend/options")
      when "categories"
        path_parameters?(:controller => "backend/categories")
      when "groups"
        path_parameters?(:controller => "backend/groups")
    end
    
    # We rescue everything because backend/hand_over and backend/take_back are failing sometimes
    rescue
      false
    
  end

end
