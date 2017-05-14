psql
CREATE USER postgres;
ALTER USER postgres WITH SUPERUSER;


rails g scaffold Producer producer_id:string:index group_number:integer account:string

rails g scaffold Product sku:string name:string product_type:string unit:string unit_cost:integer lote:integer

rails g scaffold Recipe product:references

rails g scaffold Ingredient product:references recipe:references quantity:integer

rails g scaffold ProductInSale producer:references product:references price:integer average_time:decimal

rails g scaffold PurchaseOrder po_id:string payment_method:string store_reception_id:string status:string

class Product < ApplicationRecord
  has_one :recipe
  has_many :product_in_sales
end

class Recipe < ApplicationRecord
  belongs_to :product
  has_many :ingredients
  accepts_nested_attributes_for :ingredients
end

class Ingredient < ApplicationRecord
  belongs_to :product
  belongs_to :recipe
end

class Producer < ApplicationRecord
  has_many :product_in_sales
end

#config/routes.rb
Rails.application.routes.draw do
  resources :purchase_orders
  resources :product_in_sales
  resources :ingredients
  resources :recipes
  resources :products
  resources :producers

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