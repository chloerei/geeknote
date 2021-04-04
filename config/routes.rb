Rails.application.routes.draw do
  root to: 'home#index'
  get 'sign_up', to: 'users#new', as: 'sign_up'
  resources :users, only: [:create]
  get 'sign_in', to: 'sessions#new', as: 'sign_in'
  delete 'sign_out', to: 'sessions#destroy', as: 'sign_out'
  resources :sessions, only: [:create]

  resources :posts

  get 'attachments/:key/:filename', to: 'attachments#show'

  scope '/:space_path', module: 'space', as: :space do
    root to: 'posts#index'
    resources :posts

    namespace :dashboard do
      root to: 'home#index'
      resources :posts do
        scope module: 'posts' do
          resource :preview, only: [:create]
          resource :status, only: [:update]
        end
      end
    end
  end
end
