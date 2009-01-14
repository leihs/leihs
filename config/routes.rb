ActionController::Routing::Routes.draw do |map|

    
  # For RESTful_Authentication
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  # For RESTful_ACL
  #map.error '/error', :controller => 'sessions', :action => 'error'
  #map.denied '/denied', :controller => 'sessions', :action => 'denied'

  map.backend '/backend', :controller => 'backend/inventory_pools'
  map.admin '/admin', :controller => 'admin/inventory_pools'

############################################################################
# Frontend

  map.resource :user, :member => { :visits => :get,
                                   :timeline => :get,
                                   :timeline_visits => :get,
                            #old#? :document => :get,
                                   :account => :get } do |user|
      user.resource :order, :member => { :submit => :post,
                                         :add_line => :post,
                                         :change_line => :post,
                                         :remove_lines => :post,  # OPTIMIZE method
                                         :change_time_lines => :post }
      user.resources :orders
      user.resources :contracts
  end
  map.resource :session, :member => { :authenticate => :any,
                                      :old_new => :get } # TODO 04** remove, only for offline login
  
  map.resource :frontend, :controller => 'frontend',
                          :member => { :get_inventory_pools => :any,
                                       :set_inventory_pools => :any }
                                      
  map.resources :models
  map.resources :categories
  map.resources :templates

############################################################################
# Backend

  map.namespace :backend do |backend|
    backend.resources :barcodes

    backend.resources :inventory_pools, :member => { :timeline => :get,
                                                     :timeline_visits => :get } do |inventory_pool|
      inventory_pool.acknowledge 'acknowledge', :controller => 'acknowledge', :action => 'index'
      inventory_pool.hand_over 'hand_over', :controller => 'hand_over', :action => 'index'
      inventory_pool.take_back 'take_back', :controller => 'take_back', :action => 'index'
  
      inventory_pool.resources :orders # TODO 07** also nest to user?
      inventory_pool.resources :contracts # TODO 07** also nest to user?
      inventory_pool.resources :locations do |location|
        location.resources :items
      end
      inventory_pool.resources :option_maps
      inventory_pool.resources :models, :collection => { :available_items => :any,
                                                         :new_package => :get,
                                                         :update_package => :post },
                                        :member => { :properties => :get,
                                                     :accessories => :any,
                                                     :package => :get,
                                                     :package_items => :get,
                                                     :add_package_item => :put,
                                                     :remove_package_item => :get, # OPTIMIZE method
                                                     :package_location => :any,
                                                     :images => :get } do |model|
            model.resources :categories
            model.resources :compatibles, :controller => 'models'
            model.resources :items, :member => { :location => :any,
                                                 :status => :get,
                                                 :notes => :any }
      end
      inventory_pool.resources :templates, :member => { :models => :get,
                                                        :add_model => :put }
      inventory_pool.items 'items', :controller => 'items', :action => 'index'
      inventory_pool.resources :users, :member => { :new_contract => :get,
                                                    :remind => :get,
                                                    :access_rights => :get,
                                                    :remove_access_right => :get,  # OPTIMIZE method
                                                    :add_access_right => :post } do |user|
               user.resources :acknowledge, :member => { :approve => :any,
                                                         :reject => :any,
                                                         :delete => :get,
                                                         :add_line => :any,
                                                         :change_line => :any,
                                                         :remove_lines => :any,  # OPTIMIZE method
                                                         :swap_model_line => :any,
                                                         :time_lines => :any,
                                                         :restore => :any,
                                                         :swap_user => :any,
                                                         :change_purpose => :any,
                                                         :timeline => :get }
               user.resource :hand_over, :controller => 'hand_over',
                                         :member => { :add_line => :any,
                                                      :change_line => :any,
                                                      :remove_lines => :any,  # OPTIMIZE method
                                                      :swap_model_line => :any,
                                                      :time_lines => :any,
                                                      :sign_contract => :any,
                                                      :add_option => :any,
                                                      :remove_options => :any,  # OPTIMIZE method
                                                      :assign_inventory_code => :post,
                                                      :timeline => :get,
                                                      :delete_visit => :get,
                                                      :select_location => :any,
                                                      :auto_complete_for_location_building => :get,
                                                      :auto_complete_for_location_room => :get }
                user.resource :take_back, :controller => 'take_back',
                                          :member => { :close_contract => :any,
                                                       :assign_inventory_code => :post,
                                                       :inspection => :any,
                                                       :remove_options => :any,  # OPTIMIZE method
                                                       :timeline => :get }
      end
      inventory_pool.resources :workdays, :collection => { :close => :any,
                                                           :open => :any,
                                                           :add_holiday => :post,
                                                           :delete_holiday => :get }
    end
  end
  
############################################################################
# Admin

  map.namespace :admin do |admin|
    admin.resources :inventory_pools, :member => { :locations => :get,
                                                   :add_location => :post,
                                                   :remove_location => :get,  # OPTIMIZE method
                                                   :managers => :get,
                                                   :remove_manager => :get,  # OPTIMIZE method
                                                   :add_manager => :put } do |inventory_pool|
        inventory_pool.resources :items
    end
    admin.resources :items, :member => { :model => :get,  # TODO 12** remove and nest to models ??
                                         :inventory_pool => :any,
                                         :notes => :any }
    admin.resources :models, :member => { :properties => :get,
                                          :add_property => :post,
                                          :remove_property => :get,  # OPTIMIZE method
                                          :images => :any,
                                          :accessories => :get,
                                          :add_accessory => :post,
                                          :remove_accessory => :get } do |model|  # OPTIMIZE method
        model.resources :items
        model.resources :categories
        model.resources :compatibles, :controller => 'models'
    end
    admin.resources :categories, :member => { :add_parent => :any } do |category|
        category.resources :parents, :controller => 'categories'
        category.resources :children, :controller => 'categories'
        category.resources :models
    end
    admin.resources :users, :member => { :access_rights => :get,
                                         :remove_access_right => :get,  # OPTIMIZE method
                                         :add_access_right => :post }
    admin.resources :roles
  end

############################################################################

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "frontend"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
# TODO 30** remove "map.connect" for authenticator, use named route instead
  map.connect 'authenticator/zhdk/:action/:id', :controller => 'authenticator/zhdk'
#  map.connect ':controller/:action/:id', :defaults => { :controller => 'frontend' }
#  map.connect ':controller/:action/:id.:format'
end
