class ProductInSale < ApplicationRecord
  belongs_to :producer
  belongs_to :product
  before_create :set_mine

  def set_mine
    self.mine = producer.me
  end

end
