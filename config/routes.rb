Rails.application.routes.draw do
  match "/purchase_orders/:id" => "purchase_orders#create", via: :put
  match "/purchase_orders/:id/acepted" => "purchase_orders#acepted", via: :patch
  match "/purchase_orders/:id/rejected" => "purchase_orders#rejected", via: :patch
  match "/purchase_orders/:id/cancel" => "purchase_orders#destroy", via: :DELETE
  match "/invoices/:id" => "bills#create", via: :put
  match "/invoices/:id/acepted" => "bills#acepted", via: :patch
  match "/invoices/:id/rejected" => "bills#rejected", via: :patch
  match "/invoices/:id/delivered" => "bills#delivered", via: :patch
  match "/invoices/:id/paid" => "bills#paid", via: :patch
  match "/invoices/:id/paid" => "bills#paid", via: :patch
  match "/token" => "application#token", via: :get
  resources :balances
  resources :transactions
  resources :store_houses
  resources :products
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
