Rails.application.routes.draw do
  resources :purchase_orders do
    collection do
      patch 'accept'
      patch 'reject'
      get 'get_products', to: 'purchase_orders#get_products'
      post 'created', to: 'purchase_orders#created'
    end
  end

  resources :store_houses do
    collection do
      get 'move_internally'
      post 'submit_move_internally'
      get 'move_externally'
      post 'submit_move_externally'
      get 'clean_pulmon'
      get 'clean_recepcion'
    end
  end

  resources :product_in_sales, only: [:index]
  resources :producers, only: [:index]
  resources :pending_products, only: [:index, :show]
  resources :invoices, only: [:index, :show]

  resources :factory_orders, only: [:index]

  get '/bank/', to: 'bank#index'
  get '/bank/:id', to: 'bank#show', :as => :bank_transactions

  resources :products, only: [:index, :show]
  get '/products/:id/buy_to_factory', to: 'products#buy_to_factory', :as => :buy_to_factory_product
  post '/products/:id/buy_to_factory', to: 'products#post_buy_to_factory', :as => :post_buy_to_factory_product
  get '/products/:id/confirm_buy_to_factory', to: 'products#confirm_buy_to_factory', :as => :confirm_buy_to_factory_product
  post '/products/:id/post_confirm_buy_to_factory', to: 'products#post_confirm_buy_to_factory', :as => :post_confirm_buy_to_factory_product

  get '/products/:id/buy_to_producer', to: 'products#buy_to_producer', :as => :buy_to_producer_product
  post '/products/:id/buy_to_producer', to: 'products#post_buy_to_producer', :as => :post_buy_to_producer_product
  get '/products/:id/confirm_buy_to_producer', to: 'products#confirm_buy_to_producer', :as => :confirm_buy_to_producer_product
  post '/products/:id/confirm_buy_to_producer', to: 'products#post_confirm_buy_to_producer', :as => :post_confirm_buy_to_producer_product


  get '/products/:id/produce', to: 'products#produce', :as => :produce_product
  post '/products/:id/produce', to: 'products#post_produce', :as => :post_produce_product
  get '/products/:id/confirm_produce', to: 'products#confirm_produce', :as => :confirm_produce_product
  post '/products/:id/confirm_produce', to: 'products#post_confirm_produce', :as => :post_confirm_produce_product

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
