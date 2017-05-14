Rails.application.routes.draw do
  resources :purchase_orders
  resources :product_in_sales
  resources :ingredients
  resources :recipes
  resources :products
  resources :producers
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
