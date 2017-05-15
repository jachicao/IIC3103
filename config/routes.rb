Rails.application.routes.draw do
  resources :purchase_orders
  resources :product_in_sales
  resources :ingredients
  resources :recipes
  resources :products
  resources :producers
  
  root 'purchase_orders#new'

  namespace :api, defaults: {format: 'json'} do
    get '/products', to: 'products#index'

    put '/invoices/:invoice_id', to: 'invoices#create'
    patch '/invoices/:invoice_id/accepted', to: 'invoices#update_accepted'
    patch '/invoices/:invoice_id/rejected', to: 'invoices#update_rejected'
    patch '/invoices/:invoice_id/paid', to: 'invoices#update_paid'
    patch '/invoices/:invoice_id/delivered', to: 'invoices#update_delivered'

    put '/purchase_orders/:po_id', to: 'purchase_orders#create'
    patch '/purchase_orders/:po_id/accepted', to: 'purchase_orders#update_accepted'
    patch '/purchase_orders/:po_id/rejected', to: 'purchase_orders#update_rejected'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
