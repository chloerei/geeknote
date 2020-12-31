Rails.application.routes.draw do
  root to: 'home#index'
  get 'sign_up', to: 'users#new', as: 'sign_up'
  resources :users, only: [:create]
  get 'sign_in', to: 'sessions#new', as: 'sign_in'
  delete 'sign_out', to: 'sessions#destroy', as: 'sign_out'
  resources :sessions, only: [:create]

  resources :posts
end
