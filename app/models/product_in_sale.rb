class ProductInSale < ApplicationRecord
  belongs_to :producer
  belongs_to :product

  def is_mine
    return self.producer.is_me
  end

  def self.get_mines
    result = []
    self.all.each do |product_in_sale|
      if product_in_sale.is_mine
        result.push(product_in_sale)
      end
    end
    return result
  end

  def self.get_my_product_in_sale(sku)
    Producer.get_me.product_in_sales.each do |product_in_sale|
      if product_in_sale.product.sku == sku
        return product_in_sale
      end
    end
    return nil
  end
end
