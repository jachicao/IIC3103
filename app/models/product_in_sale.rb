class ProductInSale < ApplicationRecord
  belongs_to :producer
  belongs_to :product
end
