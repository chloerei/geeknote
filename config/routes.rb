require 'sidekiq/web'
require 'sidekiq/cron/web'

class AdminConstraint
  def matches?(request)
    return false unless request.cookies['auth_token']
    user = User.find_by auth_token: request.cookies['auth_token']
    user && user.admin?
  end
end

Rails.application.routes.draw do
  root to: 'posts#index'

  get 'contact', to: 'pages#contact'

  get 'sign_up', to: 'users#new', as: 'sign_up'
  resources :users, only: [:create]
  get 'sign_in', to: 'sessions#new', as: 'sign_in'
  delete 'sign_out', to: 'sessions#destroy', as: 'sign_out'
  resources :sessions, only: [:create]

  get 'attachments/:key/*filename', to: 'attachments#show', as: :attachment

  post '/rails/active_storage/direct_uploads', to: 'direct_uploads#create'

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

  namespace :settings do
    root to: 'home#index'
    resource :email do
      post :resend
    end
    resource :password
    resource :notification
  end

  namespace :user do
    resource :password, only: [:new, :create, :edit, :update]
    namespace :email do
      resource :verification, only: [:show, :update]
      resource :unsubscribe, only: [:show, :update]
    end
  end

  namespace :admin do
    mount Sidekiq::Web => "/sidekiq", constraints: AdminConstraint.new
  end

  scope '/:account_name', module: 'account', as: :account do
    root to: 'posts#index'

    resources :posts do
      scope module: 'posts' do
        resource :preview, only: [:show]
        resource :like, only: [:create, :destroy]
        resources :collections, only: [:index, :new, :create, :update] do
          collection do
            put :switch
          end
        end
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
    resources :collections, only: [:index, :show]
    resources :likes
    resources :members, only: [:index]
    resources :tags, only: [:show]

    resource :invitation, only: [:show, :update]

    namespace :dashboard do
      root to: 'home#index'
      resources :posts do
        member do
          patch :publish
          patch :unpublish
          patch :trash
          patch :restore
        end

        scope module: 'posts' do
          resources :revisions, only: [:index, :show] do
            member do
              patch :restore
            end
          end
          resource :settings, only: [:show, :update]
          resource :featured_image, only: [:update, :destroy]
        end
      end

      resources :members do
        member do
          post :resend
        end
      end

      resources :collections do
        scope module: 'collections' do
          resources :collection_items, only: [:update, :destroy]
        end
      end

      resources :attachments, only: [:create]

      namespace :settings do
        root to: 'home#index'
        resource :profile, only: [:show, :update]
        resource :avatar, only: [:update]
        resource :banner_image, only: [:update, :destroy]
        resource :account, only: [:show, :update]
        resource :import, only: [:show, :update]
        resources :exports, only: [:index, :create, :destroy]
      end
    end
  end
end
