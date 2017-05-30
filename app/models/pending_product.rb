class PendingProduct < ApplicationRecord
  belongs_to :product
  has_many :purchased_products, :dependent => :destroy
end
