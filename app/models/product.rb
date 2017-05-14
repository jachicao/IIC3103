class Product < ApplicationRecord
  has_many :ingredients
  has_many :product_in_sales
end