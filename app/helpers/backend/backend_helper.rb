module Backend::BackendHelper
  
  def last_visitors
    #TODO: last visitors should be scoped through inventory_pool and later through selected day in daily view
    #TODO: move this inside of the inventory pools model ?
    return false if session[:last_visitors].blank?
    session[:last_visitors] = session[:last_visitors][0..3]
    session[:last_visitors].map { |x| link_to x.second, backend_inventory_pool_search_path(current_inventory_pool, :term => x.second), :class => "clickable" }.join()
  end
  
  def is_current_page?(section)
    
    #TODO: PREVENT LOOPING
    # return false if caller == is_current_page?(section)
    
    case section
      when "lending"
        is_current_page?("daily") or
        is_current_page?("orders") or
        is_current_page?("hand_over") or
        is_current_page?("take_back") or
        is_current_page?("contracts") or
        is_current_page?("visits")
      when "daily"
        current_inventory_pool and current_page?(backend_inventory_pool_path(current_inventory_pool))
      when "orders"
        current_page?(:controller => "backend/orders") ||
        !!(request.path =~ /acknowledge\/\d+$/)
      when "search"
        current_page?(:controller => "backend", :action => :search)
      when "focused_search"
        current_page?(:controller => "backend", :action => :search) and params[:types] and params[:types].size == 1
      when "hand_over"
        current_page?(:controller => "backend/hand_over", :action => :show)
      when "take_back"
        current_page?(:controller => "backend/take_back", :action => :show)
      when "contracts"
        current_page?(:controller => "backend/contracts")
      when "visits"
        current_page?(:controller => "backend/visits") or
          is_current_page?("hand_over") or
            is_current_page?("take_back")
      when "admin"
        is_current_page?("inventory_pools")
      when "inventory_pools"
        current_page?(:controller => "backend/inventory_pools", :action => :index)
      when "inventory"
        is_current_page?("models") or
          is_current_page?("items")
      when "models"
        current_page?(:controller => "backend/models")
      when "items"
        current_page?(:controller => "backend/items", :action => :show)
      when "current_user"
        current_page?(:controller => "backend/users", :action => :show) and @user == current_user
      when "start_screen"
        current_user.start_screen == request.fullpath
    end
    
    # We rescue everything because backend/hand_over and backend/take_back are failing sometimes
    rescue
      false
    
  end

end