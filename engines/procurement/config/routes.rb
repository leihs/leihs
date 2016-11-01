Procurement::Engine.routes.draw do

  root to: 'application#root'

  resources :budget_periods, only: [:index, :create, :destroy]

  resources :requests, only: [] do
    collection do
      get :overview
    end
  end

  resources :users, only: [:index, :create] do
    resources :budget_periods, only: [] do
      resources :requests, only: :new
      scope format: true, constraints: {format: ['csv', 'xlsx']} do
        resources :requests, only: :index
      end
    end
  end

  resources :categories, only: [:index, :create] do
    resources :budget_periods, only: [] do
      resources :users, only: [] do
        collection do
          get :choose
        end
        resources :requests, only: [:index, :create, :destroy] do
          member do
            put :move
          end
        end
      end
    end
    scope format: true, constraints: {format: ['csv', 'xlsx']} do
      resources :budget_periods, only: [] do
        resources :requests, only: [:index]
      end
    end
  end

  resources :templates, only: [:index, :create]

  resources :models, only: :index
  resources :suppliers, only: :index
  resources :locations, only: :index

  resources :organizations, only: :index

  resource :settings, only: [:edit, :create]

end
