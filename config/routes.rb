Rails.application.routes.draw do

  root to: "application#root"

  # Authenticator
  match 'authenticator/zhdk/login', to: 'authenticator/zhdk#login', via: [:get, :post]
  match 'authenticator/zhdk/login_successful/:id', to: 'authenticator/zhdk#login_successful', via: [:get, :post]
  match 'authenticator/db/:action', controller: 'authenticator/database_authentication', via: [:get, :post]
  match 'authenticator/ldap/:action', controller: 'authenticator/ldap_authentication', via: [:get, :post]
  match 'authenticator/hslu/:action', controller: 'authenticator/hslu_authentication', via: [:get, :post]
  match 'authenticator/shibboleth/login', to: 'authenticator/shibboleth_authentication#login', via: [:get, :post]
  match 'authenticator/login', to: "authenticator/database_authentication#login", via: [:get, :post]

  # For RESTful_Authentication
  match 'login',                      to: 'sessions#new', as: :login,                via: [:get, :post]
  match 'logout',                     to: 'sessions#destroy',                        via: [:get, :post]

  # Session
  get 'session/authenticate', to: 'sessions#authenticate'

  # Categories
  get "categories/:id/image", to: "categories#image", as: "category_image"
  get "category_links",       to: "category_links#index", as: "category_links"

  # Styleguide
  get "styleguide",           to: "styleguide#show"
  get "styleguide/:section",  to: "styleguide#show"

  # Models
  get "models/:id/image",       to: "models#image", as: "model_image"
  get "models/:id/image_thumb", to: "models#image", as: "model_image_thumb", size: :thumb

  # Properties
  get "properties", to: "properties#index", as: "properties"

  mount LeihsAdmin::Engine => '/admin', :as => 'admin'
  mount Procurement::Engine => '/procurement', :as => 'procurement'

  # Borrow Section
  namespace :borrow do
    root to: "application#root"
    
    # maintenance
    get "maintenance", to: "application#maintenance"

    get "availability", to: "availability#show", as: "availability"
    get "holidays", to: "holidays#index", as: "holidays"
    get "inventory_pools", to: "inventory_pools#index", as: "inventory_pools"

    get "categories", to: "categories#index"
    get "groups", to: "groups#index"

    get "models",               to: "models#index", as: "models"
    get "models/availability",  to: "models#availability", as: "models_availability"
    get "models/:id",           to: "models#show", as: "model"

    get     "order",        to: "contracts#current", as: "current_order"
    post    "order",        to: "contracts#submit"
    delete  "order/remove", to: "contracts#remove"
    post    "reservations",                   to: "reservations#create"
    post    "reservations/change_time_range", to: "reservations#change_time_range", as: "change_time_range"
    delete  "reservations/:line_id",          to: "reservations#destroy"
    delete  "order/remove_reservations", to: "contracts#remove_reservations"
    get     "order/timed_out", to: "contracts#timed_out"
    post    "order/delete_unavailables", to: "contracts#delete_unavailables"
    get     "orders", to: "contracts#index", as: "orders"

    get "refresh_timeout", to: "application#refresh_timeout"
    get "returns", to: "returns#index", as: "returns"

    post  'search',               to: 'search#search',  as: "search"
    get   'search',               to: 'search#results', as: "search_results"

    get   'templates',                  to: 'templates#index',        as: "templates"
    get   'templates/:id',              to: 'templates#show',         as: "template"
    post  'templates/:id',              to: 'templates#select_dates', as: "template_select_dates"
    post  'templates/:id/availability', to: 'templates#availability', as: "template_availability"
    post  'templates/:id/add_to_order', to: 'templates#add_to_order', as: "template_add_to_order"

    get "to_pick_up", to: "to_pick_up#index", as: "to_pick_up"
    get "workdays", to: "workdays#index", as: "workdays"

    get "user",                           to: "users#current",              as: "current_user"
    get "user/documents",                 to: "users#documents",            as: "user_documents"
    get "user/contracts/:id",             to: "users#contract",             as: "user_contract"
    get "user/value_lists/:id",           to: "users#value_list",           as: "user_value_list"
    get "user/delegations",               to: "users#delegations",          as: "user_delegations"
    post "user/switch_to_delegation/:id", to: "users#switch_to_delegation", as: "user_switch_to_delegation"
    get "user/switch_back",               to: "users#switch_back",          as: "user_switch_back"
  end

  # Manage Section
  namespace :manage do
    root to: "application#root"

    # Administrate inventory pools
    # get     'inventory_pools',                         to: 'inventory_pools#index'
    # get     'inventory_pools/new',                     to: 'inventory_pools#new',      as: 'new_inventory_pool'
    # post    'inventory_pools',                         to: 'inventory_pools#create'
    get     'inventory_pools/:inventory_pool_id/edit', to: 'inventory_pools#edit',     as: 'edit_inventory_pool'
    put     'inventory_pools/:inventory_pool_id',      to: 'inventory_pools#update',   as: 'update_inventory_pool'
    # delete  'inventory_pools/:inventory_pool_id',      to: 'inventory_pools#destroy',  as: 'delete_inventory_pool'

    # Users
    post 'users/:id/set_start_screen', to: 'users#set_start_screen'

    # Locations
    get     'locations',          to: 'locations#index'

    scope ":inventory_pool_id/" do

      # maintenance
      get 'maintenance', to: 'application#maintenance'

      ## Availability
      get 'availabilities',           to: 'availability#index', as: 'inventory_pool_availabilities'
      get 'availabilities/in_stock',  to: 'availability#in_stock'

      ## Daily
      get 'daily', to: "inventory_pools#daily", as: "daily_view"

      ## Contracts
      get   'contracts',                  to: "contracts#index",      as: "contracts"
      get   "contracts/:id",              to: "contracts#show",       as: "contract"
      post  "contracts/:id/approve",      to: "contracts#approve",    as: "approve_contract"
      post  "contracts/:id/reject",       to: "contracts#reject"
      post  'contracts/:id/sign',         to: "contracts#sign"
      get   'contracts/:id/edit',         to: "contracts#edit",       as: "edit_contract"
      post  'contracts/:id/swap_user',    to: "contracts#swap_user"
      get   "contracts/:id/value_list",   to: "contracts#value_list", as: "value_list"
      get   "contracts/:id/picking_list", to: "contracts#picking_list", as: "picking_list"

      ## Visits
      delete  'visits/:visit_id',        to: 'visits#destroy'
      post    'visits/:visit_id/remind', to: 'visits#remind'
      get     'visits/hand_overs',       to: 'visits#index',     status: "approved"
      get     'visits/take_backs',       to: 'visits#index',     status: "signed"
      get     'visits',                  to: "visits#index",     as: "inventory_pool_visits"

      ## Workload
      get 'workload', to: 'inventory_pools#workload'

      ## Latest Reminder
      get 'latest_reminder', to: 'inventory_pools#latest_reminder'

      ## Purposes
      put 'purposes/:purpose_id', to: "purposes#update"
      get 'purposes',             to: "purposes#index"

      ## Workdays
      get 'workdays', to: "workdays#index"

      ## Holidays
      get 'holidays', to: "holidays#index"

      ## Reservations
      get     "reservations",                        to: "reservations#index"
      post    "reservations",                        to: "reservations#create"
      delete  "reservations",                        to: "reservations#destroy"
      post    "reservations/swap_user",              to: "reservations#swap_user"
      post    "reservations/swap_model",             to: "reservations#swap_model"
      post    "reservations/assign_or_create",       to: "reservations#assign_or_create"
      post    "reservations/change_time_range",      to: "reservations#change_time_range"
      post    "reservations/for_template",           to: "reservations#create_for_template"
      post    "reservations/:id/assign",             to: "reservations#assign"
      post    "reservations/:id/remove_assignment",  to: "reservations#remove_assignment"
      put     "reservations/:line_id",               to: "reservations#update"
      delete  "reservations/:line_id",               to: "reservations#destroy"
      post    "reservations/take_back",              to: "reservations#take_back"
      post    "reservations/print",                  to: "reservations#print", as: "print_reservations"

      # Inventory
      get 'inventory',                  :to => "inventory#index",       :as => "inventory"
      get 'inventory/csv',              :to => "inventory#csv_export",  :as => "inventory_csv_export"
      get 'inventory/csv_import',       :to => "inventory#csv_import"
      post 'inventory/csv_import',      :to => "inventory#csv_import"
      get 'inventory/helper',           :to => "inventory#helper",      :as => "inventory_helper"
      get 'inventory/:inventory_code',  :to => "inventory#show"

      # Models
      get     'models',                       to: "models#index",     as: "models"
      post    'models',                       to: "models#create",    as: "create_model"
      get     'models/new',                   to: "models#new",       as: "new_model"
      get     'models/:id/timeline',          to: "models#timeline"
      put     'models/:id',                   to: "models#update"
      get     'models/:id',                   to: "models#show"
      delete  'models/:id',                   to: "models#destroy"
      get     'models/:id/edit',              to: "models#edit",      as: "edit_model"
      post    'models/:id/upload/image',      to: "models#upload",    type: "image"
      post    'models/:id/upload/attachment', to: "models#upload",    type: "attachment"

      # Categories
      get     'categories',                       to: 'categories#index',           as: 'categories'
      post    'categories',                       to: 'categories#create'
      get     'categories/new',                   to: 'categories#new',             as: 'new_category'
      get     'categories/:id/edit',              to: 'categories#edit',            as: 'edit_category'
      put     'categories/:id',                   to: 'categories#update',          as: 'update_category'
      delete  'categories/:id',                   to: 'categories#destroy'
      post    'categories/:id/upload/image',      to: "categories#upload",          type: "image"

      # Options
      get   'options',            to: "options#index"
      post  'options',            to: "options#create",     as: "create_option"
      get   'options/new',        to: "options#new",        as: "new_option"
      get   'options/:id/edit',   to: "options#edit",       as: "edit_option"
      put   'options/:id',        to: "options#update",     as: "update_option"

      # Items
      get   'items',                    to: "items#index"
      post  'items',                    to: "items#create",           as: "create_item"
      get   'items/new',                to: "items#new",              as: "new_item"
      get   'items/current_locations',  to: "items#current_locations"
      get   'items/:id',                to: "items#show"
      put   'items/:id',                to: "items#update",           as: "update_item"
      get   'items/:id/edit',           to: "items#edit",             as: "edit_item"
      get   'items/:id/copy',           to: "items#copy",             as: "copy_item"
      post  'items/:id/inspect',        to: "items#inspect"

      # Partitions
      get 'partitions', to: "partitions#index"

      # Groups
      get     'groups',           to: "groups#index",      as: "inventory_pool_groups"
      get     'groups/:id/edit',  to: "groups#edit",       as: "edit_inventory_pool_group"
      get     'groups/new',       to: "groups#new",        as: "new_inventory_pool_group"
      post    'groups',           to: "groups#create"
      put     'groups/:id',       to: "groups#update",     as: "update_inventory_pool_group"
      delete  'groups/:id',       to: "groups#destroy",    as: "delete_inventory_pool_group"

      # ModelLinks
      get 'model_links', to: "model_links#index"

      # Templates
      get     'templates',              to: "templates#index",        as: "templates"
      post    'templates',              to: "templates#create"
      get     'templates/new',          to: "templates#new",          as: "new_template"
      get     'templates/:id/edit',     to: "templates#edit",         as: "edit_template"
      put     'templates/:id',          to: "templates#update",       as: "update_template"
      delete  'templates/:id',          to: "templates#destroy",      as: "delete_template"

      # Users
      get      "users",          to: "users#index",                     as: "inventory_pool_users"
      get      "users/new",      to: "users#new",     as: "new_inventory_pool_user"
      post     "users",          to: "users#create",  as: "create_inventory_pool_user"
      get      "users/:id/edit", to: "users#edit",    as: "edit_inventory_pool_user"
      put      "users/:id",      to: "users#update",  as: "update_inventory_pool_user"

      get      'users/:id/hand_over', to: "users#hand_over", as: "hand_over"
      get      'users/:id/take_back', to: "users#take_back", as: "take_back"

      # Access rights
      get "access_rights", to: "access_rights#index"

      # Fields
      get 'fields', to: 'fields#index', as: 'fields'
      post 'fields/:id', to: 'fields#hide'
      delete 'fields', to: 'fields#reset'

      # Search
      post 'search',               to: 'search#search',        as: "search"
      get  'search',               to: 'search#results',       as: "search_results"
      get  'search/models',        to: "search#models",        as: "search_models"
      get  'search/software',      to: "search#software",      as: "search_software"
      get  'search/items',         to: "search#items",         as: "search_items"
      get  'search/licenses',      to: "search#licenses",      as: "search_licenses"
      get  'search/users',         to: "search#users",         as: "search_users"
      get  'search/contracts',     to: "search#contracts",     as: "search_contracts"
      get  'search/orders',        to: "search#orders",        as: "search_orders"
      get  'search/options',       to: "search#options",       as: "search_options"

      # Mail templates
      get 'mail_templates', to: 'mail_templates#index'
      get 'mail_templates/:dir/:name', to: 'mail_templates#edit'
      put 'mail_templates/:dir/:name', to: 'mail_templates#update'

      # Buildings
      get     'buildings',          to: 'buildings#index'
      get     'buildings/:id/edit', to: 'buildings#edit',     as: 'edit_inventory_pool_building'
      delete  'buildings/:id',      to: 'buildings#destroy',  as: 'delete_inventory_pool_building'

      # Suppliers
      get     'suppliers',          to: 'suppliers#index'
      get     'suppliers/:id',      to: 'suppliers#show',     as: 'inventory_pool_supplier'
      delete  'suppliers/:id',      to: 'suppliers#destroy',  as: 'delete_inventory_pool_supplier'

    end

  end

  if Rails.env.test? or Rails.env.development?
    get "/images/attachments/:dir1/:dir2/:file", to: redirect('/images/test.jpg')
    get "/attachments/:dir1/:dir2/:file", to: redirect('/images/test.jpg')
  end

end
