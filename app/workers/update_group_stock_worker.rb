class UpdateGroupStockWorker < ApplicationWorker
  sidekiq_options queue: 'low'

  def perform(group_number)
    producer = Producer.find_by(group_number: group_number)
    if producer != nil
      if producer.has_wrong_products_api
        producer.product_in_sales.each do |product_in_sale|
          product_in_sale.update(price: product_in_sale.product.unit_cost, stock: 0)
        end
      else
        response = self.get_group_prices(group_number)
        if response[:code] == 200
          begin
            body = JSON.parse(response[:body], symbolize_names: true)
            producer.product_in_sales.each do |product_in_sale|
              found = false
              body.each do |product|
                if product[:sku] == product_in_sale.product.sku
                  found = true
                  precio = product[:precio]
                  if product[:price] != nil
                    precio = product[:price]
                  end
                  product_in_sale.update(price: precio, stock: product[:stock])
                end
              end
              if found
              else
                product_in_sale.update(price: product_in_sale.product.unit_cost, stock: 0)
              end
            end
          rescue Exception => e
            puts e
          end
        else
          producer.product_in_sales.each do |product_in_sale|
            product_in_sale.update(price: product_in_sale.product.unit_cost, stock: 0)
          end
        end
      end
    end
  end
end