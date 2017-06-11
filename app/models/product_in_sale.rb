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
end
