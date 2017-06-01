class ProductInSale < ApplicationRecord
  belongs_to :producer
  belongs_to :product

  def is_mine
    return self.producer.is_me
  end

  def get_price()
    return self.price
  end

  def do_i_produce(sku)
    products = ProductInSale.where(product_id: Product.where(sku: sku).select("id").first)
    products.each do |product|
      if product.is_mine
        return product
      end
    end
    return nil
  end
end
