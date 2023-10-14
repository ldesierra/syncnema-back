Rails.application.routes.draw do
  resources :users, only: [:create]
  resources :ratings, only: [:create, :update]
  resources :favourites, only: [:create, :index, :destroy]
end
