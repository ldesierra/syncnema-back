Rails.application.routes.draw do
  resources :users, only: [:create, :destroy]

  resources :ratings, only: [:create] do
    put :update, on: :collection
  end

  resources :favourites, only: [:create, :index] do
    delete :destroy, on: :collection
  end

  resources :contents, only: [:show, :index]

  root to: 'home#index'
end
