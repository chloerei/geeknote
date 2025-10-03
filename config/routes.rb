Rails.application.routes.draw do
  root to: "home#index"
  get "following", to: "home#following", as: :following
  get "newest", to: "home#newest", as: :newest
  get "home/sidebar", to: "home#sidebar", as: :home_sidebar

  get "/search", to: "search#index", as: :search

  resource :session, only: [ :new, :create, :destroy ]
  resource :registration, only: [ :new, :create ]

  resources :attachments, only: [ :create ]
  get "/attachments/:key(/*filename)", to: "attachments#show", as: :attachment

  post "/rails/active_storage/direct_uploads", to: "direct_uploads#create"

  resource :preview, only: [ :create ]

  resources :tags, only: [ :show ], id: /.+/, format: false, defaults: { format: :html }

  namespace :suggest do
    resources :tags, only: [ :index ]
  end

  resources :organizations, only: [ :new, :create ]
  resources :notifications, only: [ :index ]
  resources :bookmarks, only: [ :index ]

  namespace :settings do
    root to: "home#index"
    resource :email do
      post :resend
    end
    resource :password
    resource :notification
  end

  namespace :identity do
    resource :password, only: [ :new, :create, :edit, :update ]
    namespace :email do
      resource :verification, only: [ :show, :update ]
      resource :unsubscribe, only: [ :show, :update ]
    end
  end

  namespace :admin do
    root to: "home#index"

    resources :posts do
      member do
        patch :restrict
        patch :unrestrict
      end
    end

    resources :tags do
      scope module: :tags do
        resource :merge, only: [ :new, :create ]
      end
    end

    resources :comments
    resources :accounts
    resources :users
    resources :organizations

    namespace :settings do
      root to: "home#index"
      resource :appearance, only: [ :show, :update ]
      resource :weekly_digest, only: [ :show, :update ] do
        scope module: :weekly_digests do
          resource :preview, only: [ :show, :create ]
        end
      end
    end

    mount MissionControl::Jobs::Engine, at: "/jobs"
  end

  get "up", to: "rails/health#show", as: :rails_health_check

  scope "/dashboard/:account_name", module: "dashboard", as: :dashboard do
    root to: "home#index"
    resources :posts, only: [ :index, :new, :create, :edit, :update, :destroy ] do
      collection do
        post "preview"
      end

      scope module: :posts do
        resource :publish, only: [ :update, :destroy ]
      end
    end

    namespace :analytics do
      root to: "home#index"
    end

    namespace :settings do
      root to: "home#index"
      resource :profile, only: [ :show, :update ]
      resources :members
      resource :import, only: [ :show, :update ]
      resource :export, only: [ :show, :create ]
    end
  end

  scope "/:account_name", module: "account", as: :account do
    root to: "posts#index"

    resources :posts do
      scope module: "posts" do
        resource :preview, only: [ :show ]
        resource :like, only: [ :create, :destroy ]
        resource :bookmark, only: [ :create, :destroy ]
        resources :comments, only: [ :index ]
        resources :views, only: [ :create ]
      end
    end

    resources :comments do
      scope module: "comments" do
        resource :like, only: [ :create, :destroy ]
      end
    end

    get "/search", to: "search#index", as: :search

    get "/feed", to: "feed#index", as: :feed

    resource :follow, only: [ :create, :destroy ]
    resources :followings, only: [ :index ]
    resources :followers, only: [ :index ]
    resources :likes
    resources :members, only: [ :index ]

    resource :invitation, only: [ :show, :update ]
  end

  direct :custom_imgproxy_active_storage do |model, options|
    if ImgproxyRails::Helpers.applicable_variation?(model)
      transformations = model.variation.transformations
      Imgproxy.url_for(model.blob, ImgproxyRails::Transformer.call(transformations))
    else
      # Use redirect instead of proxy
      route_for(:rails_storage_redirect, model, options)
    end
  end
end
