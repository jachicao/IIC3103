class FactoryOrder < ApplicationRecord
  belongs_to :product

  def self.make_product(sku, cantidad, costo_unitario)
    if cantidad > 5000
      return false
    end
    BuyFactoryProductsJob.perform_later(sku, cantidad, costo_unitario)
    return true
  end
end
