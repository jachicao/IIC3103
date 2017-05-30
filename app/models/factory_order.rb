class FactoryOrder < ApplicationRecord
  def self.make_product(sku, cantidad, costo_unitario)
    BuyFactoryProductsJob.perform_later(sku, cantidad, costo_unitario)
  end
end
