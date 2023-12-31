Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  resources :users, only: [:create, :destroy]

  resources :ratings, only: [:create] do
    put :update, on: :collection
  end

  resources :favourites, only: [:create, :index] do
    delete :destroy, on: :collection
  end

  resources :contents, only: [:show, :index] do
    get :provenance, on: :collection
  end

  resources :genres, only: [:index]
  resources :platforms, only: [:index]

  root to: 'home#index'
end
