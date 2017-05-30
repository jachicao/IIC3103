class PurchasedProduct < ApplicationRecord
  belongs_to :product
  belongs_to :producer
  belongs_to :pending_product
end
