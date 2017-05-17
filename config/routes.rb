Rails.application.routes.draw do
  resources :factory_orders
  resources :purchase_orders
  resources :product_in_sales
  resources :ingredients
  resources :products
  resources :producers

  get '/make_products', to: 'factory#new'
  get '/make_products_details', to: 'factory#detalles'
  post '/make_products', to: 'factory#submit_producir'

  get '/store_house', to: 'store_house#index'

  namespace :api, defaults: { format: 'json' } do
    get '/products', to: 'api_products#index'

    put '/invoices/:invoice_id', to: 'api_invoices#create'
    patch '/invoices/:invoice_id/accepted', to: 'api_invoices#update_accepted'
    patch '/invoices/:invoice_id/rejected', to: 'api_invoices#update_rejected'
    patch '/invoices/:invoice_id/paid', to: 'api_invoices#update_paid'
    patch '/invoices/:invoice_id/delivered', to: 'api_invoices#update_delivered'

    put '/purchase_orders/:po_id', to: 'api_purchase_orders#create'
    patch '/purchase_orders/:po_id/accepted', to: 'api_purchase_orders#update_accepted'
    patch '/purchase_orders/:po_id/rejected', to: 'api_purchase_orders#update_rejected'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
