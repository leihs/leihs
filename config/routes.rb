Leihs::Application.routes.draw do

  root :to => "application#index"

  # Authenticator
  match 'authenticator/zhdk/login', :to => 'authenticator/zhdk#login'
  match 'authenticator/zhdk/login_successful/:id', :to => 'authenticator/zhdk#login_successful'
  match 'authenticator/db/:action', :to => 'authenticator/database_authentication'
  match 'authenticator/ldap/:action', :to => 'authenticator/ldap_authentication'
  match 'authenticator/hslu/:action', :to => 'authenticator/hslu_authentication'
  match 'authenticator/shibboleth/:action/:id', :to => 'authenticator/shibboleth_authentication'

  # For RESTful_Authentication
  match 'activate/:activation_code', :to => 'users#activate', :activation_code => nil
  match 'signup', :to => 'users#new'
  match 'login', :to => 'sessions#new'
  match 'logout', :to => 'sessions#destroy'
  match 'switch_to_ldap', :to => 'sessions#switch_to_ldap' #TODO 1009: Remove when not used anymore
  
  # Backend
  match 'backend', :to => "backend/backend#index"
  get 'backend/inventory_pools/:inventory_pool_id/inventory', :to => "backend/inventory#index", :as => "backend_inventory_pool_inventory"

  # Borrow Section
  namespace :borrow do
    get "/", :to => "application#start", :as => "start"
    get "inventory_pools", :to => "inventory_pools#index", :as => "inventory_pools"

    get "categories", :to => "categories#index"

    get "models", :to => "models#index", :as => "models"
    get "models/availability", :to => "models#availability", :as => "models_availability"
    get "models/:id", :to => "models#show", :as => "model"

    get "order", :to => "orders#unsubmitted_order", :as => "unsubmitted_order"
    post "order", :to => "orders#submit"
    delete "order/remove", :to => "orders#remove"
    post "order/add_line", :to => "orders#add_line"
    delete "order/remove_lines", :to => "orders#remove_lines"
    get "order/timed_out", :to => "orders#timed_out"
    get "orders", :to => "orders#index", :as => "orders"

    get "returns", :to => "returns#index", :as => "returns"
    post 'search', :to => 'search#search', :as => "search"
    get 'search/:search_term', :to => 'search#results', :as => "search_results"
    get "to_pick_up", :to => "to_pick_up#index", :as => "to_pick_up"
    get "user", :to => "users#current", :as => "current_user"
  end

  # Categories
  get "categories/:id/image", :to => "categories#image", :as => "category_image"
  get "category_links", :to => "category_links#index", :as => "category_links"

  # Styleguide
  get "styleguide", :to => "styleguide#show"
  get "styleguide/:section", :to => "styleguide#show"

  # Models
  get "models/:id/image", :to => "models#image", :as => "model_image"
  get "models/:id/image_thumb", :to => "models#image_thumb", :as => "model_image_thumb"

  # Properties
  get "properties", to: "properties#index", as: "properties"

  # Users scoped by inventory pool
  get "backend/inventory_pools/:inventory_pool_id/users/new", to: "backend/users#new_in_inventory_pool", as: "new_backend_inventory_pool_user"
  post "backend/inventory_pools/:inventory_pool_id/users", to: "backend/users#create_in_inventory_pool", as: "create_backend_inventory_pool_user"
  get "backend/inventory_pools/:inventory_pool_id/users/:id/edit", to: "backend/users#edit_in_inventory_pool", as: "edit_backend_inventory_pool_user"
  put "backend/inventory_pools/:inventory_pool_id/users/:id", to: "backend/users#update_in_inventory_pool", as: "update_backend_inventory_pool_user"

  # Users
  delete "backend/users/:id", to: "backend/users#destroy", as: "delete_backend_user"

############################################################################
##### Following things are old and have to be checked if still used
#####
############################################################################

  # used for the current_user
  resource :user do
    resources :orders do #TODO#, :only => [:show, :destroy]
      member do
        get :submitted
      end
    end
    resources :contracts
  end

=begin
  # used for the current_order
  resource :order do
    member do
      post :submit
      post :add_line
      delete :remove_lines
      post :change_time_lines
    end
  end
=end

  resource :session do
    member do
      get :authenticate # TODO 2012 both needed? 
      post :authenticate # TODO 2012 both needed? 
      get :old_new # TODO 05** remove, only for offline login
    end
  end

  resource :authenticator do
    match 'login', :to => "authenticator/database_authentication#login"
  end

  resources :categories do 
    resources :models
  end

  resources :templates do 
    resources :models
  end

  resources :inventory_pools

  ############################################################################
  # Backend

  namespace :backend do
    #tmp# match 'database_backup', :to => 'backend#database_backup'

    root :to => "backend#index"
    match 'search', :to => 'backend#search'

    resources :barcodes

    resources :users do
      member do
        get :extended_info
        post :update_badge_id
        post :set_start_screen
      end
    end

    resources :mails

    resources :fields, :controller => "fields", :only => :index

    resources :inventory_pools do
      member do
        get :workload
      end

      # http://localhost:3000/backend/inventory_pools/1/items/new

      resources :acknowledge, :except => :index do
        member do
          post :approve
          get :reject
          post :reject
          get :delete
          post :add_line
          post :update_lines
          delete :remove_lines
          post :swap_user
          post :change_purpose
        end
      end
      match 'search', :to => 'backend#search'

      resources :mails

      resources :orders
      resources :contracts
      resources :visits, :only => :index
      resource :inventory_helper, :controller => "inventory_helper", :only => :show

      resources :locations
      resources :categories do
        member do
          #rails3# OPTIMIZE
          get :add_parent
          post :add_parent
          put :add_parent
          delete :add_parent
        end
        resources :parents, :controller => 'categories'
        resources :children, :controller => 'categories'
        resources :models
      end
      resources :options
      resources :models do
        collection do
          get :new_package
          post :update_package
        end
        member do
          get :timeline
            #leihs2#begin# check out what we need 
            get :details
            get :properties
          post :properties
          get :package
          delete :destroy_package
          put :update_package
          get :package_roots
          post :package_roots
          put :package_roots
          delete :package_roots
          get :package_item
          put :package_item
          delete :package_item
          post :set_group_partition
          #leihs2#end# 
        end
        resources :compatibles, :controller => 'models'
        resources :items do
          member do
            get :status
            get :notes
            post :notes
            get :show 
            post :toggle_permission
            post :get_notes
          end
        end
      end
      resources :templates do
        member do
          get :models
          put :add_model
        end
      end
      resources :items do
        collection do
          get :supplier
          post :supplier
          get :inventory_codes
          put :update
          get :find
        end
        member do
          get :status
          get :notes
          post :notes
          post :toggle_permission
          post :get_notes
          post :retire
          get :copy
        end
      end
      resources :users do
        member do
          get :new_contract
          get :remind
          get :extended_info
          get :things_to_return
          get :groups
          put :add_group
          delete :remove_group
        end
        resource :hand_over, :controller => 'hand_over' do
          member do
            get :add_line
            post :add_line
            post :add_line_with_item # TODO 29**
            delete :remove_lines
            post :update_lines
            get :swap_model_line
            post :swap_model_line
            post :sign_contract
            get :add_option
            post :add_option
            post :assign_inventory_code
            delete :delete_visit
            post :swap_user 
          end
        end
        resource :take_back, :controller => 'take_back' do
          member do
            post :close_contract
            post :assign_inventory_code
            get :things_to_return
            post :inspection
            post :update_lines
          end
        end
      end
      resources :workdays do
        collection do
          get :close # OPTIMIZE post (ajax)
          get :open # OPTIMIZE post (ajax)
          post :add_holiday
          get :delete_holiday # OPTIMIZE post (ajax)
        end
      end
      resources :groups do
        member do
          get :users
          put :add_user
        end
      end
      #old leihs# resource :availability, :controller => 'availability'
    end
  end

  ############################################################################
  # Statistics

=begin
  namespace :statistics do
    root :to => "statistics#index"

    resources :statistics, :only => :index

    match ':type/:id', :to => 'statistics#show'
    match ':type/:id/activities', :to => 'statistics#activities'
  end  
=end

  resource :statistics, :only => :show do
    member do
      get :activities  
    end

    match ':type/:id/activities', :to => 'statistics#activities'
    #match ':type/:id', :to => 'statistics#show'
  end

end
