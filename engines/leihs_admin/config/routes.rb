LeihsAdmin::Engine.routes.draw do

  root to: redirect('/admin/inventory_pools')

  resources :buildings,       except: :show
  resources :inventory_pools, except: :show
  resources :locations,       only: :destroy
  resources :scenarios,       only: :index
  resources :statistics,      only: [:index, :show]
  resources :suppliers,       except: :show
  resources :users,           except: :show

  # Audits
  get 'audits',           to: 'audits#index'
  get ':type/:id/audits', to: 'audits#index'

  # Database Check
  get "database/indexes", to: "database#indexes"
  match "database/empty_columns", to: "database#empty_columns", as: "empty_columns", via: [:get, :delete]
  match "database/consistency", to: "database#consistency", as: "consistency", via: [:get, :delete]
  match "database/access_rights", to: "database#access_rights", as: "access_rights", via: [:get, :post]
  get "database/not_null_columns", to: "database#not_null_columns"

  # Export inventory of all inventory pools
  get 'inventory/csv',              :to => 'inventory#csv_export',  :as => 'global_inventory_csv_export'

  # Fields
  get 'fields', to: 'fields#index'
  put 'fields', to: 'fields#update'

  # Administrate settings
  get 'settings', to: 'settings#edit'
  put 'settings', to: 'settings#update'

  # Mail templates
  get 'mail_templates', to: 'mail_templates#index'
  get 'mail_templates/:dir/:name', to: 'mail_templates#edit'
  put 'mail_templates/:dir/:name', to: 'mail_templates#update'

end
