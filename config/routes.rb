Rails.application.routes.draw do
  root to: 'home#index'
  get 'sign_up', to: 'users#new', as: 'sign_up'
  resources :users, only: [:create]
  get 'sign_in', to: 'sessions#new', as: 'sign_in'
  delete 'sign_out', to: 'sessions#destroy', as: 'sign_out'
  resources :sessions, only: [:create]

  get 'attachments/:key/:filename', to: 'attachments#show'

  resources :tags, only: [] do
    collection do
      get :search
    end
  end

  resources :organizations, only: [:new, :create]

  namespace :settings do
    resource :account
    resource :password
    resources :organizations, only: [:index]
  end

  scope '/:account_name', module: 'account', as: :account do
    root to: 'posts#index'

    resources :posts do
      scope module: 'posts' do
        resource :preview, only: [:show]
      end
    end

    resource :invitation, only: [:show, :update]

    namespace :dashboard do
      root to: 'home#index'
      resources :posts do
        scope module: 'posts' do
          resource :status, only: [:update]
          resource :settings, only: [:show, :update]
          resource :featured_image, only: [:update, :destroy]
        end
      end
      resources :memberships do
        member do
          post :resend
        end
      end

      namespace :settings do
        resource :profile, onlu: [:show, :update]
      end
    end
  end
end
