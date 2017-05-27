Rails.application.routes.draw do
  resources :purchase_orders do
    collection do
      patch 'accept'
      patch 'reject'
      get 'get_products', to: 'purchase_orders#get_products'
      post 'created', to: 'purchase_orders#created'
    end
  end

  resources :store_houses, only: [:index, :show]
  get '/store_houses/move_internally', to: 'store_houses#move_internally'
  post '/store_houses/submit_move_internally', to: 'store_houses#submit_move_internally'
  get '/store_houses/move_externally', to: 'store_houses#move_externally'
  post '/store_houses/submit_move_externally', to: 'store_houses#submit_move_externally'
  get '/store_houses/clean_pulmon', to: 'store_houses#clean_pulmon'
  get '/store_houses/clean_recepcion', to: 'store_houses#clean_recepcion'

  resources :factory_orders, only: [:index]

  get '/bank/', to: 'bank#index'
  get '/bank/:id', to: 'bank#show', :as => :bank_transactions

  resources :products, only: [:index, :show]
  get '/products/:id/produce', to: 'products#produce', :as => :produce_product
  post '/products/:id/produce', to: 'products#post_produce', :as => :post_produce_product
  get '/products/:id/purchase_items', to: 'products#purchase_items', :as => :purchase_items_product
  get '/products/:id/post_purchase_items', to: 'products#post_purchase_items', :as => :post_purchase_items_product

  root 'dashboard#index'
  get '/dashboard', to: 'dashboard#index'

  namespace :api, constraints: { format: 'json' } do
    get '/products', to: 'api_products#index'
    get '/publico/precios', to: 'api_products#get_stock'
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
end
