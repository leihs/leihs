Leihs::Application.routes.draw do

  root to: "application#root"

  # Authenticator
  match 'authenticator/zhdk/login',                 to: 'authenticator/zhdk#login',                    via: [:get, :post]
  match 'authenticator/zhdk/login_successful/:id',  to: 'authenticator/zhdk#login_successful',         via: [:get, :post]
  match 'authenticator/db/:action',                 to: 'authenticator/database_authentication',       via: [:get, :post]
  match 'authenticator/ldap/:action',               to: 'authenticator/ldap_authentication',           via: [:get, :post]
  match 'authenticator/hslu/:action',               to: 'authenticator/hslu_authentication',           via: [:get, :post]
  match 'authenticator/shibboleth/login',     to: 'authenticator/shibboleth_authentication#login',     via: [:get, :post]
  match 'authenticator/login',                      to: "authenticator/database_authentication#login", via: [:get, :post]

  # For RESTful_Authentication
  match 'activate/:activation_code',  to: 'users#activate', :activation_code => nil, via: [:get, :post]
  match 'signup',                     to: 'users#new',                               via: [:get, :post]
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

  namespace :admin do
    # Statistics
    get "statistics", to: "statistics#show", as: "statistics"

    # Database Check
    get "database/indexes", to: "database#indexes"
    match "database/empty_columns", to: "database#empty_columns", as: "empty_columns", via: [:get, :delete]
    match "database/consistency", to: "database#consistency", as: "consistency", via: [:get, :delete]
    match "database/access_rights", to: "database#access_rights", as: "access_rights", via: [:get, :post]

    # Test report
    get "scenarios", to: "scenarios#index"
  end

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
    post    "contract_lines",                   to: "contract_lines#create"
    post    "contract_lines/change_time_range", to: "contract_lines#change_time_range", as: "change_time_range"
    delete  "contract_lines/:line_id",          to: "contract_lines#destroy"
    delete  "order/remove_lines", to: "contracts#remove_lines"
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
    
    # maintenance
    get "maintenance", to: "application#maintenance"

    # Location
    get 'locations', to: "locations#index"

    # Building
    get     'buildings',          to: 'buildings#index'
    get     'buildings/new',      to: 'buildings#new',      as: 'new_building'
    post    'buildings',          to: 'buildings#create'
    get     'buildings/:id/edit', to: 'buildings#edit',     as: 'edit_building'
    put     'buildings/:id',      to: 'buildings#update',   as: 'update_building'
    delete  'buildings/:id',      to: 'buildings#destroy',  as: 'delete_building'

    # Users
    post "users/:user_id/set_start_screen", to: "users#set_start_screen"

    # # Users
    # delete "manage/users/:id", to: "manage/users#destroy", as: "delete_manage_user"

    # Administrate inventory pools
    get     'inventory_pools',          to: 'inventory_pools#index'
    get     'inventory_pools/new',      to: 'inventory_pools#new',      as: 'new_inventory_pool'
    post    'inventory_pools',          to: 'inventory_pools#create'
    get     'inventory_pools/:id/edit', to: 'inventory_pools#edit',     as: 'edit_inventory_pool'
    put     'inventory_pools/:id',      to: 'inventory_pools#update',   as: 'update_inventory_pool'
    delete  'inventory_pools/:id',      to: 'inventory_pools#destroy',  as: 'delete_inventory_pool'

    # Export inventory of all inventory pools
    get 'inventory/csv',              :to => "inventory#csv_export",  :as => "global_inventory_csv_export"

    # Administrate users
    get     'users',          to: 'users#index'
    get     'users/new',      to: 'users#new'
    get     'users/:id/edit', to: 'users#edit',   as: 'edit_user'
    post    'users',          to: 'users#create', as: 'create_user'
    put     'users/:id',      to: 'users#update', as: 'update_user'
    delete  'users/:id',      to: 'users#destroy'

    # Access rights
    get "access_rights", to: "access_rights#index"

    # Administrate settings
    get 'settings', to: 'settings#edit',    as: 'edit_settings'
    put 'settings', to: 'settings#update',  as: 'update_settings'

    # Mail templates
    get 'mail_templates', to: 'mail_templates#index'
    get 'mail_templates/:dir/:name', to: 'mail_templates#edit'
    put 'mail_templates/:dir/:name', to: 'mail_templates#update'

    scope ":inventory_pool_id/" do

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
      get   'contracts/:id/hand_over',    to: "contracts#hand_over",  as: "hand_over_contract"
      post  'contracts/:id/swap_user',    to: "contracts#swap_user"
      get   "contracts/:id/value_list",   to: "contracts#value_list", as: "value_list"
      get   "contracts/:id/picking_list", to: "contracts#picking_list", as: "picking_list"

      ## Visits
      delete  'visits/:visit_id',        to: 'visits#destroy'
      post    'visits/:visit_id/remind', to: 'visits#remind'
      get     'visits/hand_overs',       to: 'visits#index',     type: "hand_over"
      get     'visits/take_backs',       to: 'visits#index',     type: "take_back"
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

      ## ContractLines
      get     "contract_lines",                        to: "contract_lines#index"
      post    "contract_lines",                        to: "contract_lines#create"
      delete  "contract_lines",                        to: "contract_lines#destroy"
      post    "contract_lines/swap_user",              to: "contract_lines#swap_user"
      post    "contract_lines/assign_or_create",       to: "contract_lines#assign_or_create"
      post    "contract_lines/change_time_range",      to: "contract_lines#change_time_range"
      post    "contract_lines/for_template",           to: "contract_lines#create_for_template"
      post    "contract_lines/:id/assign",             to: "contract_lines#assign"
      post    "contract_lines/:id/remove_assignment",  to: "contract_lines#remove_assignment"
      put     "contract_lines/:line_id",               to: "contract_lines#update"
      delete  "contract_lines/:line_id",               to: "contract_lines#destroy"
      post    "contract_lines/take_back",              to: "contract_lines#take_back"
      post    "contract_lines/print",                  to: "contract_lines#print", as: "print_contract_lines"

      # Hand Over
      get 'users/:user_id/hand_over', to: "users#hand_over", as: "hand_over"

      # Take Back
      get 'users/:user_id/take_back', to: "users#take_back", as: "take_back"

      # Inventory
      get 'inventory',                  :to => "inventory#index",       :as => "inventory"
      get 'inventory/csv',              :to => "inventory#csv_export",  :as => "inventory_csv_export"
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
      get      "users/new",      to: "users#new_in_inventory_pool",     as: "new_inventory_pool_user"
      post     "users",          to: "users#create_in_inventory_pool",  as: "create_inventory_pool_user"
      get      "users/:id/edit", to: "users#edit_in_inventory_pool",    as: "edit_inventory_pool_user"
      put      "users/:id",      to: "users#update_in_inventory_pool",  as: "update_inventory_pool_user"
      delete   "users/:id",      to: "users#destroy"

      # Access rights
      get "access_rights", to: "access_rights#index"

      # Fields
      get 'fields', to: "fields#index", as: "fields"

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

    end

  end

  if Rails.env.test? or Rails.env.development?
    get "/images/attachments/:dir1/:dir2/:file", to: redirect('/images/test.jpg')
    get "/attachments/:dir1/:dir2/:file", to: redirect('/images/test.jpg')
  end

end
