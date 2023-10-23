Rails.application.routes.draw do
  resources :users, only: [:create]
  resources :ratings, only: [:create, :update]
  resource :recommendations, only: [:show]
  resources :favourites, only: [:create, :index, :destroy]
end
