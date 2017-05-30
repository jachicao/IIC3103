class ProductInSale < ApplicationRecord
  belongs_to :producer
  belongs_to :product

  def is_mine
    return self.producer.is_me
  end
end
