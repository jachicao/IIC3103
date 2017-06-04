class Producer < ApplicationRecord
  has_many :product_in_sales

  def self.get_me
    return Producer.find_by(group_number: ENV['GROUP_NUMBER'].to_i)
  end

  def is_me
    return self.group_number == ENV['GROUP_NUMBER'].to_i
  end

  def has_wrong_api
    invalid_groups = [4, 6, 8] #TODO: remove this
    return invalid_groups.include?(self.group_number)
  end

  def get_price_of_product(sku)
    response = GetGroupPricesJob.perform_now(self.group_number)
    case response[:code]
      when 200..226
        response[:body].each do |product|
          if product[:sku] == sku
            if product[:price] != nil
              return product[:price]
            end
            if product[:precio] != nil
              return product[:precio]
            end
          end
        end
    end
    return Product.find_by(sku: sku).unit_cost
  end

  def get_product_details(sku)
    response = GetGroupPricesJob.perform_now(self.group_number)
    case response[:code]
      when 200..226
        response[:body].each do |product|
          if product[:sku] == sku
            precio = product[:precio]
            if product[:price] != nil
              precio = product[:price]
            end
            return { precio: precio, sku: product[:sku], stock: product[:stock] }
          end
        end
    end
    return { precio: Product.find_by(sku: sku).unit_cost, sku: sku, stock: 0 }
  end
end