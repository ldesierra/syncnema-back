Rails.application.routes.draw do
  resources :users, only: [:create, :destroy]

  resources :ratings, only: [:create] do
    put :update, on: :collection
  end

  resource :recommendations, only: [:show]

  resources :favourites, only: [:create, :index] do
    delete :destroy, on: :collection
  end

  root to: 'home#index'
end
