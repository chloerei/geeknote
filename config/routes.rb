Rails.application.routes.draw do
  root to: 'posts#index'

  get 'sign_up', to: 'users#new', as: 'sign_up'
  resources :users, only: [:create]
  get 'sign_in', to: 'sessions#new', as: 'sign_in'
  delete 'sign_out', to: 'sessions#destroy', as: 'sign_out'
  resources :sessions, only: [:create]

  get 'attachments/:key/*filename', to: 'attachments#show', as: :attachment

  resources :posts, only: [] do
    collection do
      get :following
      get :latest
    end
  end

  resources :tags, only: [:show] do
    collection do
      get :search
    end
  end

  resources :organizations, only: [:index, :new, :create]
  resources :notifications, only: [:index]
  resources :bookmarks, only: [:index, :update, :destroy] do
    collection do
      get :archived
    end
  end

  namespace :settings do
    resource :account
    resource :password
  end

  namespace :user do
    resource :password, only: [:new, :create, :edit, :update]
  end

  scope '/:account_name', module: 'account', as: :account do
    root to: 'posts#index'

    resources :posts do
      scope module: 'posts' do
        resource :preview, only: [:show]
        resource :like, only: [:create, :destroy]
        resource :bookmark, only: [:create, :destroy]
        resources :comments do
          scope module: 'comments' do
            resource :like, only: [:create, :destroy]
          end
        end
      end
    end

    get '/feed', to: 'feed#index', as: :feed

    resource :follow, only: [:create, :destroy]
    resources :followings, only: [:index]
    resources :followers, only: [:index]
    resources :likes
    resources :members, only: [:index]
    resources :tags, only: [:show]

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

      resources :members do
        member do
          post :resend
        end
      end

      resources :attachments, only: [:create]

      resources :settings, only: [:index]
      namespace :settings do
        resource :profile, only: [:show, :update]
        resource :avatar, only: [:update]
        resource :banner_image, only: [:update, :destroy]
      end
    end
  end
end
