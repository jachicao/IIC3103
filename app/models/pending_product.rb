class PendingProduct < ApplicationRecord
  belongs_to :product
  has_many :purchased_products, :dependent => :destroy


  def has_stock
    ready = self.quantity > 0
    self.product.ingredients.each do |ingredient|
      if ingredient.item.stock >= ingredient.quantity
      else
        ready = false
      end
    end
    return ready
  end
end
