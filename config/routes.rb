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
  resources :factory_orders do
    collection do
      post 'make_products'
    end
  end
  resources :product_in_sales
  resources :ingredients
  resources :products
  resources :producers

  root 'dashboard#index'
  get '/dashboard', to: 'dashboard#index'

  namespace :api, constraints: { format: 'json' } do
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
end
