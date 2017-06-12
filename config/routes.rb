require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  mount Sidekiq::Web => '/sidekiq'
  mount Spree::Core::Engine, at: '/spree/'

  resources :purchase_orders, only: [:index, :show, :destroy]
  patch '/purchase_orders/:id/accept', to: 'purchase_orders#accept', :as => :accept
  patch '/purchase_orders/:id/reject', to: 'purchase_orders#reject', :as => :reject
  patch '/purchase_orders/:id/create_invoice', to: 'purchase_orders#create_invoice', :as => :create_invoice_purchase_order

  get '/store_houses/move_internally', to: 'store_houses#move_internally', :as => :move_internally_store_house
  post '/store_houses/move_internally', to: 'store_houses#submit_move_internally', :as => :post_move_internally_store_house
  resources :store_houses, only: [:index, :show]

  resources :product_in_sales, only: [:index]
  resources :producers, only: [:index]
  resources :pending_products, only: [:index, :destroy]

  get 'create_bill_web/:id', to: 'invoices#create_bill_web', as: :create_bill_web

  resources :invoices, only: [:index, :show]
  post '/invoices/:id/pay', to: 'invoices#pay', :as => :pay

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
    patch '/invoices/:invoice_id/accepted', to: 'api_invoices#accepted'
    patch '/invoices/:invoice_id/rejected', to: 'api_invoices#rejected'
    patch '/invoices/:invoice_id/paid', to: 'api_invoices#paid'
    patch '/invoices/:invoice_id/delivered', to: 'api_invoices#delivered'

    put '/purchase_orders/:po_id', to: 'api_purchase_orders#create'
    patch '/purchase_orders/:po_id/accepted', to: 'api_purchase_orders#accepted'
    patch '/purchase_orders/:po_id/rejected', to: 'api_purchase_orders#rejected'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
