ActionController::Routing::Routes.draw do |map|

    
  # For RESTful_Authentication
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.ldap '/switch_to_ldap', :controller => 'sessions', :action => 'switch_to_ldap' #TODO 1009: Remove when not used anymore
  # For RESTful_ACL
  #map.error '/error', :controller => 'sessions', :action => 'error'
  #map.denied '/denied', :controller => 'sessions', :action => 'denied'

  map.backend '/backend', :controller => 'backend/inventory_pools'
  map.inventory '/inventory', :controller => 'inventory/inventory_pools'

############################################################################
# Frontend

  map.resource :user, :member => { :visits => :get,
                                   :timeline => :get,
                                   :timeline_visits => :get,
                            #old#? :document => :get,
                                   :account => :get } do |user|
      user.resource :order, :member => { :submit => :post,
                                         :add_line => :post,
                                         :change_line_quantity => :post,
                                         :remove_lines => :delete,
                                         :change_time_lines => :post }
      user.resources :orders
      user.resources :contracts
  end
  map.resource :session, :member => { :authenticate => :any, :old_new => :get } # TODO 05** remove, only for offline login
  map.resource :authenticator do | auth |
    auth.login 'login', :controller => "Authenticator::DatabaseAuthentication", :action => 'login'
  end
  map.resource :frontend, :controller => 'frontend',
                          :member => { :get_inventory_pools => :get,
                                       :set_inventory_pools => :get }
                                      
  map.resources :models, :member => { :chart => :get }
  map.resources :categories
  map.resources :templates

############################################################################
# Backend

  map.namespace :backend do |backend|
    backend.resources :barcodes

    backend.resources :users, :member => { :access_rights => :get,
                                          :add_access_right => :post,
                                          :remove_access_right => :delete,
                                          #:suspend_access_right => :post,
                                          #:reinstate_access_right => :post,
                                          :extended_info => :get,
                                          :update_badge_id => :post }
                                                    
    backend.resources :inventory_pools, :member => { :timeline => :get,
                                                     :timeline_visits => :get} do |inventory_pool|
      inventory_pool.acknowledge 'acknowledge', :controller => 'acknowledge', :action => 'index'
      inventory_pool.hand_over 'hand_over', :controller => 'hand_over', :action => 'index'
      inventory_pool.take_back 'take_back', :controller => 'take_back', :action => 'index'
  
      inventory_pool.resources :orders # TODO 07** also nest to user?
      inventory_pool.resources :contracts # TODO 07** also nest to user?
      inventory_pool.resources :locations do |location|
        location.resources :items
      end
      inventory_pool.resources :categories, :member => { :add_parent => :any } do |category|
        category.resources :parents, :controller => 'categories'
        category.resources :children, :controller => 'categories'
        category.resources :models
      
      end
      inventory_pool.resources :options
      inventory_pool.resources :models, :collection => { :new_package => :get,
                                                         :update_package => :post },
                                        :member => { :properties => :any,
                                                     :accessories => :any,
                                                     :package => :get,
                                                     :destroy_package => :delete,
                                                     :update_package => :put,
                                                     :package_roots => :any,
                                                     :package_item => :any,
                                                     :categories => :any,
                                                     :images => :any } do |model|
            model.resources :compatibles, :controller => 'models'
            model.resources :items, :member => { :location => :any,
                                                 :status => :get,
                                                 :notes => :any,
                                                 :show => :any, 
                                                 :toggle_permission => :post,
                                                 :retire => :any,
                                                 :get_notes => :any 
                                                 }
      end
      inventory_pool.resources :templates, :member => { :models => :get,
                                                        :add_model => :put }
      #inventory_pool.items 'items', :controller => 'items', :action => 'index'
      inventory_pool.resources :items, :collection => { :supplier => :any },
                                          :member => { :location => :any,
                                                 :status => :get,
                                                 :notes => :any,
                                                 :show => :any, 
                                                 :toggle_permission => :post,
                                                 :get_notes => :any, :notes => :any 
                                                 }
      inventory_pool.resources :users, :member => { :new_contract => :get,
                                                    :remind => :get,
                                                    :access_rights => :get,
                                                    :add_access_right => :post,
                                                    :remove_access_right => :delete,
                                                    :suspend_access_right => :post,
                                                    :reinstate_access_right => :post,
                                                    :extended_info => :get,
                                                    :things_to_return => :get,
                                                    :update_badge_id => :post } do |user|
               user.resources :acknowledge, :member => { :approve => :any,
                                                         :reject => :any,
                                                         :delete => :get,
                                                         :add_line => :any,
                                                         :change_line_quantity => :any,
                                                         :remove_lines => :any, # OPTIMIZE [:get, :delete] (from Rails 2.2)
                                                         :swap_model_line => :any,
                                                         :time_lines => :any,
                                                         :restore => :any,
                                                         :swap_user => :any,
                                                         :change_purpose => :any,
                                                         :timeline => :get }
               user.resource :hand_over, :controller => 'hand_over',
                                         :member => { :add_line => :any,
                                                      :add_line_with_item => :post, # TODO 29**
                                                      :change_line_quantity => :post,
                                                      :change_line => :any,
                                                      :remove_lines => :any, # OPTIMIZE [:get, :delete] (from Rails 2.2)
                                                      :swap_model_line => :any,
                                                      :time_lines => :any,
                                                      :sign_contract => :any,
                                                      :add_option => :any,
                                                      :assign_inventory_code => :post,
                                                      :timeline => :get,
                                                      :delete_visit => :delete,
                                                      :select_location => :any,
                                                      :swap_user => :any, 
                                                      :set_purpose => :post }
                user.resource :take_back, :controller => 'take_back',
                                          :member => { :close_contract => :any,
                                                       :assign_inventory_code => :post,
                                                       :inspection => :any,
                                                       :time_lines => :any,
                                                       :timeline => :get }
      end
      inventory_pool.resources :workdays, :collection => { :close => :any,
                                                           :open => :any,
                                                           :add_holiday => :post,
                                                           :delete_holiday => :get }
    end
  end
  
############################################################################

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "frontend"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
# TODO 30** remove "map.connect" for authenticator, use named route instead
  map.connect 'authenticator/zhdk/:action/:id', :controller => 'authenticator/zhdk'
  map.connect 'authenticator/db/:action/:id', :controller => 'authenticator/database_authentication'
  map.connect 'authenticator/ldap/:action/:id', :controller => 'authenticator/ldap_authentication'
#  map.connect ':controller/:action/:id', :defaults => { :controller => 'frontend' }
#  map.connect ':controller/:action/:id.:format'
end
