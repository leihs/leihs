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

  map.resource :user do |user|
      user.resources :orders #TODO#, :only => [:show, :destroy]
      user.resource :order, :member => { :submit => :post,
                                         :add_line => :post,
                                         :change_line_quantity => :post,
                                         :remove_lines => :delete,
                                         :change_time_lines => :post }
      user.resources :contracts
  end
  map.resource :session, :member => { :authenticate => [:get, :post], # TODO 2012 both needed? 
                                      :old_new => :get } # TODO 05** remove, only for offline login
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
    backend.database_backup 'database_backup', :controller => 'backend', :action => 'database_backup'
    
    backend.resources :barcodes

    backend.resources :users, :member => { :access_rights => :get,
                                          :add_access_right => :post,
                                          :remove_access_right => :delete,
                                          :extended_info => :get,
                                          :update_badge_id => :post }
 
    backend.resources :mails

    backend.resources :inventory_pools do |inventory_pool|
      inventory_pool.acknowledge 'acknowledge', :controller => 'acknowledge', :action => 'index'
      inventory_pool.hand_over 'hand_over', :controller => 'hand_over', :action => 'index'
      inventory_pool.take_back 'take_back', :controller => 'take_back', :action => 'index'
      inventory_pool.search 'search', :controller => 'backend', :action => 'search'
  
      inventory_pool.resources :mails

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
                                        :member => { :details => :get,
                                                     :groups => :get,
                                                     :properties => [:get, :post],
                                                     :accessories => :any,
                                                     :package => :get,
                                                     :destroy_package => :delete,
                                                     :update_package => :put,
                                                     :package_roots => :any,
                                                     :package_item => [:get, :put, :delete],
                                                     :categories => [:get, :post],
                                                     :images => [:get, :post, :delete],
                                                     :attachments => [:get, :post, :delete],
                                                     :set_group_partition => :post } do |model|
            model.resources :compatibles, :controller => 'models'
            model.resources :items, :member => { :location => [:get, :post, :put],
                                                 :status => :get,
                                                 :notes => [:get, :post],
                                                 :show => :get, 
                                                 :toggle_permission => :post,
                                                 :retire => [:get, :post],
                                                 :get_notes => :post
                                                 }
      end
      inventory_pool.resources :templates, :member => { :models => :get,
                                                        :add_model => :put }
      inventory_pool.resources :items, :collection => { :supplier => [:get, :post],
                                                        :inventory_codes => :get },
                                          :member => { :location => [:get, :post, :put],
                                                       :status => :get,
                                                       :notes => [:get, :post],
                                                       :show => :get, 
                                                       :toggle_permission => :post,
                                                       :get_notes => :post
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
                                                    :groups => :get,
                                                    :add_group => :put,
                                                    :remove_group => :delete,
                                                    :update_badge_id => :post } do |user|
               user.resources :acknowledge, :member => { :approve => [:get, :post],
                                                         :reject => [:get, :post],
                                                         :delete => :get,
                                                         :add_line => [:get, :post],
                                                         :change_line_quantity => :post,
                                                         :remove_lines => [:get, :delete],
                                                         :swap_model_line => [:get, :post],
                                                         :time_lines => [:get, :post],
                                                         :restore => [:get, :post],
                                                         :swap_user => [:get, :post],
                                                         :change_purpose => [:get, :post] }
               user.resource :hand_over, :controller => 'hand_over',
                                         :member => { :add_line => [:get, :post],
                                                      :add_line_with_item => :post, # TODO 29**
                                                      :change_line_quantity => :post,
                                                      :change_line => :post,
                                                      :remove_lines => [:get, :delete],
                                                      :swap_model_line => [:get, :post],
                                                      :time_lines => [:get, :post],
                                                      :sign_contract => [:get, :post],
                                                      :add_option => [:get, :post],
                                                      :assign_inventory_code => :post,
                                                      :delete_visit => :delete,
                                                      :swap_user => [:get, :post], 
                                                      :set_purpose => :post }
                user.resource :take_back, :controller => 'take_back',
                                          :member => { :close_contract => [:get, :post],
                                                       :assign_inventory_code => :post,
                                                       :inspection => [:get, :post],
                                                       :time_lines => [:get, :post] }
      end
      inventory_pool.resources :workdays, :collection => { :close => :get, # OPTIMIZE post (ajax)
                                                           :open => :get, # OPTIMIZE post (ajax)
                                                           :add_holiday => :post,
                                                           :delete_holiday => :get } # OPTIMIZE post (ajax)
      inventory_pool.resources :groups, :member => { :users => :get,
                                                     :add_user => :put }
      inventory_pool.resource :availability, :controller => 'availability'
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
  map.connect 'authenticator/hslu/:action/:id', :controller => 'authenticator/hslu_authentication'
  map.connect 'authenticator/shibboleth/:action/:id', :controller => 'authenticator/shibboleth_authentication'

#  map.connect ':controller/:action/:id', :defaults => { :controller => 'frontend' }
#  map.connect ':controller/:action/:id.:format'
end
