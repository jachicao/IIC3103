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
  put '/purchase_orders/:po_id', to: 'purchase_orders#api_create'

  get '/store_houses/move_internally', to: 'store_houses#move_internally', :as => :move_internally_store_house
  post '/store_houses/move_internally', to: 'store_houses#submit_move_internally', :as => :post_move_internally_store_house
  resources :store_houses, only: [:index, :show]

  resources :product_in_sales, only: [:index]
  resources :producers, only: [:index]
  resources :pending_products, only: [:index, :destroy]
  resources :promotions, only: [:index, :destroy]


  post 'spree_orders/:id', to: 'spree_orders#create_bill', as: :create_bill

  resources :invoices, only: [:index, :show]
  put '/invoices/:invoice_id', to: 'invoices#api_create'

  post '/invoices/:id/pay', to: 'invoices#pay', :as => :pay

  get '/bills/:id/paid', to: 'invoices#paid', :as => :bill_paid
  get '/bills/:id/failed', to: 'invoices#failed', :as => :bill_failed

  resources :factory_orders, only: [:index]

  get '/bank/', to: 'bank#index'
  get '/bank/:id', to: 'bank#show', :as => :bank_transactions

  resources :products, only: [:index, :show]
  get '/products/:id/buy', to: 'products#buy', :as => :buy_product
  post '/products/:id/buy', to: 'products#post_buy', :as => :post_buy_product
  get '/products/:id/confirm_buy', to: 'products#confirm_buy', :as => :confirm_buy_product
  post '/products/:id/confirm_buy', to: 'products#post_confirm_buy', :as => :post_confirm_buy_product

  root 'dashboard#index'
  get '/dashboard', to: 'dashboard#index'

  namespace :api, constraints: { format: 'json' } do
    get '/products', to: 'api_products#index'
    get '/publico/precios', to: 'api_products#get_stock'
    put '/invoices/:invoice_id', to: 'api_invoices#create'

    put '/purchase_orders/:po_id', to: 'api_purchase_orders#create'
    patch '/purchase_orders/:po_id/accepted', to: 'api_purchase_orders#accepted'
    patch '/purchase_orders/:po_id/rejected', to: 'api_purchase_orders#rejected'

    patch '/invoices/:invoice_id/accepted', to: 'api_invoices#accepted'
    patch '/invoices/:invoice_id/rejected', to: 'api_invoices#rejected'
    patch '/invoices/:invoice_id/paid', to: 'api_invoices#paid'
    patch '/invoices/:invoice_id/delivered', to: 'api_invoices#delivered'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
