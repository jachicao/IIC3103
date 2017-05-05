Rails.application.routes.draw do
  resources :balances
  resources :transactions
  resources :store_houses
  resources :products
  resources :bills
  resources :purchase_orders
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
