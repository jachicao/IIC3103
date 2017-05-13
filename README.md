psql
CREATE USER postgres;
ALTER USER postgres WITH SUPERUSER;


rails g scaffold Producer producer_id:string group_number:integer account:string

rails g scaffold Product sku:string name:string price:integer type:string unit_cost:integer lote:integer

rails g scaffold Recipe product_sku:string ingredient_sku:string quantity:integer

rails g scaffold PurchaseOrder po_id:string payment_method:string id_reception:string status:string

rails g scaffold Ingredient producer_id:string sku:string quantity:integer



class Product < ApplicationRecord
  has_many :recipes
  has_many :ingredients, through: :recipes
end

class Recipe < ApplicationRecord
  belongs_to :product
  belongs_to :ingredient
end

class Ingredient < ApplicationRecord
  belongs_to :producer
  has_many :recipe
end

class Producer < ApplicationRecord
  has_many :ingredients
end
