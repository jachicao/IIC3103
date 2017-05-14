class Product < ApplicationRecord
  has_one :recipe
  has_many :product_in_sales
end