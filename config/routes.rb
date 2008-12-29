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

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  map.resource :user, :member => { :visits => :get,
                                   :timeline => :get,
                                   :timeline_visits => :get,
                            #old#? :document => :get,
                                   :account => :get } do |user|
      user.resource :order, :member => { :submit => :post,
                                         :add_line => :post,
                                         :change_line => :post,
                                         :remove_lines => :post,
                                         :change_time_lines => :post }
      user.resources :orders
      user.resources :contracts
  end
  map.resource :session, :member => { :authenticate => :any,
                                      :old_new => :get } # TODO 04** remove, only for offline login
  
  map.resource :frontend, :controller => 'frontend',
                          :member => { :get_inventory_pools => :any,
                                       :set_inventory_pools => :any }
                                      
  map.resources :models, :collection => { :categories => :any }

############################################################################

  map.namespace :backend do |backend|
    backend.resources :barcodes

    backend.resources :inventory_pools, :member => { :timeline => :get,
                                                     :timeline_visits => :get } do |inventory_pool|
      inventory_pool.acknowledge 'acknowledge', :controller => 'acknowledge', :action => 'index'
      inventory_pool.hand_over 'hand_over', :controller => 'hand_over', :action => 'index'
      inventory_pool.take_back 'take_back', :controller => 'take_back', :action => 'index'
  
      inventory_pool.resources :orders # TODO 07** also nest to user?
      inventory_pool.resources :contracts # TODO 07** also nest to user?
      inventory_pool.resources :locations
      inventory_pool.resources :option_maps
#old#      inventory_pool.resources :items, :collection => { :auto_complete => :get }  # TODO 12** nest to model
      inventory_pool.items 'items', :controller => 'items', :action => 'index'
      inventory_pool.auto_complete 'auto_complete', :controller => 'items', :action => 'auto_complete' # TODO 12** optimize
      inventory_pool.resources :models, :collection => { :auto_complete => :get, # TODO 17** merge all 'auto_complete' methods into 'index'
                                                         :available_items => :any,
                                                         :new_package => :get,
                                                         :update_package => :post },
                                        :member => { :properties => :get,
                                                     :accessories => :any,
                                                     :show_package => :get,
                                                     :show_package_items => :get,
                                                     :add_package_item => :put,
                                                     :remove_package_item => :get,
                                                     :package_location => :any,
                                                     :images => :get } do |model|
            model.resources :items, :member => { :location => :any,
                                                 :status => :get,
                                                 :notes => :any }
            model.resources :categories
            model.resources :compatibles, :controller => 'models'
      end
      inventory_pool.resources :users, :member => { :new_contract => :get,
                                                    :remind => :get,
                                                    :access_rights => :get,
                                                    :remove_access_right => :get,
                                                    :add_access_right => :post } do |user|
               user.resources :acknowledge, :member => { :approve => :any,
                                                         :reject => :any,
                                                         :delete => :get,
                                                         :add_line => :any,
                                                         :change_line => :any,
                                                         :remove_lines => :any,
                                                         :swap_model_line => :any,
                                                         :time_lines => :any,
                                                         :restore => :any,
                                                         :swap_user => :any,
                                                         :change_purpose => :any,
                                                         :timeline => :get }
               user.resource :hand_over, :controller => 'hand_over',
                                         :member => { :add_line => :any,
                                                      :change_line => :any,
                                                      :remove_lines => :any,
                                                      :swap_model_line => :any,
                                                      :time_lines => :any,
                                                      :sign_contract => :any,
                                                      :add_option => :any,
                                                      :remove_options => :any,
                                                      :assign_inventory_code => :post,
                                                      :timeline => :get,
                                                      :delete_visit => :get,
                                                      :select_location => :any,
                                                      :auto_complete_for_location_building => :post,
                                                      :auto_complete_for_location_room => :post }
                user.resource :take_back, :controller => 'take_back',
                                          :member => { :close_contract => :any,
                                                       :assign_inventory_code => :post,
                                                       :inspection => :any,
                                                       :remove_options => :any,
                                                       :timeline => :get }
      end
      inventory_pool.resources :workdays, :collection => { :close => :any,
                                                           :open => :any,
                                                           :add_holiday => :post,
                                                           :delete_holiday => :get }
    end
  end
  
############################################################################

  map.namespace :admin do |admin|
    admin.resources :inventory_pools, :member => { :locations => :get,
                                                   :add_location => :post,
                                                   :remove_location => :get,
                                                   :managers => :get,
                                                   :remove_manager => :get,
                                                   :add_manager => :put } do |inventory_pool|
        inventory_pool.resources :items
    end
    admin.resources :items, :member => { :model => :get,  # TODO 12** remove and nest to models ??
                                         :inventory_pool => :any,
                                         :notes => :any }
    admin.resources :models, :collection => { :auto_complete => :get },
                             :member => { :properties => :get,
                                          :add_property => :post,
                                          :remove_property => :get,
                                          :images => :any,
                                          :accessories => :get,
                                          :add_accessory => :post,
                                          :remove_accessory => :get } do |model|
        model.resources :items
        model.resources :categories
        model.resources :compatibles, :controller => 'models'
    end
    admin.resources :categories, :collection => { :auto_complete => :get },
                                 :member => { :add_parent => :any } do |category|
        category.resources :parents, :controller => 'categories'
        category.resources :children, :controller => 'categories'
        category.resources :models
    end
    admin.resources :users, :collection => { :auto_complete => :get },
                            :member => { :access_rights => :get,
                                         :remove_access_right => :get,
                                         :add_access_right => :post }
    admin.resources :roles
  end

############################################################################

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "frontend"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
# TODO 30** remove "map.connect"
  map.connect 'authenticator/zhdk/:action/:id', :controller => 'authenticator/zhdk'
#  map.connect ':controller/:action/:id', :defaults => { :controller => 'frontend' }
#  map.connect ':controller/:action/:id.:format'
end
