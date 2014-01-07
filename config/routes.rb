Store::Application.routes.draw do
  resources :agencies
  resources :agency_imports
  resources :deliveries
  resources :password_lists do
    resources :agencies
    resources :agency_imports
    resources :deliveries
    member do
      post :deliver
    end
  end
  root to: 'password_lists#index'
end
