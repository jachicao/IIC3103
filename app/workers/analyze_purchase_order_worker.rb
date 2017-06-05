class AnalyzePurchaseOrderWorker
  include Sidekiq::Worker

  def get_factory_analysis(sku, quantity)
    analysis = nil
    product = Product.find_by(sku: sku)
    while analysis.nil?
      analysis = product.get_factory_analysis(quantity)
      if analysis.nil?
        puts 'AnalyzePurchaseOrderWorker: sleeping server-rate seconds'
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      end
    end
    return analysis
  end

  def get_ingredients_analysis(sku, quantity)
    analysis = nil
    product = Product.find_by(sku: sku)
    while analysis.nil?
      analysis = product.get_ingredients_analysis(quantity)
      if analysis.nil?
        puts 'AnalyzePurchaseOrderWorker: sleeping server-rate seconds'
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      end
    end
    return analysis
  end

  def perform(po_id)
    purchase_order = PurchaseOrder.find_by(po_id: po_id)
    if purchase_order.supplier_id == ENV['GROUP_ID']
      my_product_in_sale = ProductInSale.get_my_product_in_sale(purchase_order.sku)
      if my_product_in_sale != nil
        if purchase_order.unit_price >= my_product_in_sale.price
          product = my_product_in_sale.product
          difference = purchase_order.quantity - product.get_stock_available
          if difference > 0
            unit_lote = (difference.to_f / product.lote.to_f).ceil
            if (DateTime.current + my_product_in_sale.average_time.to_f.hours) <= purchase_order.delivery_date
              if product.ingredients.size > 0
                purchase_items = []
                reject = false
                product.ingredients.each do |ingredient|
                  difference_ingredient = ingredient.quantity * unit_lote - ingredient.item.get_stock_available
                  if difference_ingredient > 0
                    me = false
                    ingredient.item.product_in_sales.each do |product_in_sale|
                      if product_in_sale.is_mine
                        if ingredient.item.ingredients.size > 0

                        else
                          if (DateTime.current + (my_product_in_sale.average_time + product_in_sale.average_time).to_f.hours) <= purchase_order.delivery_date
                            me = true
                            purchase_items.push({ quantity: difference_ingredient,
                                                  producer_id: product_in_sale.producer.producer_id,
                                                  sku: ingredient.item.sku })
                          end
                          break
                        end
                      end
                    end
                    if me
                    else
                      best_product_in_sale = nil
                      best_product_in_sale_price = 0
                      #comprar a los que tienen stock
                      ingredient.item.product_in_sales.each do |product_in_sale|
                        if product_in_sale.is_mine
                        else
                          if product_in_sale.producer.has_wrong_api
                          else
                            producer_details = product_in_sale.producer.get_product_details(ingredient.item.sku)
                            if producer_details[:stock] >= difference_ingredient
                              if best_product_in_sale.nil? || best_product_in_sale_price > producer_details[:precio]
                                best_product_in_sale = product_in_sale
                                best_product_in_sale_price = producer_details[:precio]
                              end
                            end
                          end
                        end
                      end
=begin
                    if best_product_in_sale.nil?
                      #comprar a los que no tienen stock
                      ingredient.item.product_in_sales.each do |product_in_sale|
                        if product_in_sale.is_mine
                        else
                          if product_in_sale.producer.has_wrong_api
                          else
                            producer_details = product_in_sale.producer.get_product_details(ingredient.item.sku)
                            if (DateTime.current + product_in_sale.average_time.to_f.hours) <= purchase_order.delivery_date
                              if best_product_in_sale.nil? || best_product_in_sale_price > producer_details[:precio]
                                best_product_in_sale = product_in_sale
                                best_product_in_sale_price = producer_details[:precio]
                              end
                            end
                          end
                        end
                      end
                    end
=end
                      if best_product_in_sale != nil
                        purchase_items.push({
                                                quantity: difference_ingredient,
                                                producer_id: best_product_in_sale.producer.producer_id,
                                                sku: ingredient.item.sku,
                                                price: best_product_in_sale_price,
                                                time: best_product_in_sale.average_time })
                      else
                        reject = true
                      end
                    end
                  end
                end
                if reject
                  purchase_order.reject_purchase_order('Stock insuficiente')
                else
                  purchase_items.each do |purchase_item|
                    puts purchase_item
                    item = Product.find_by(sku: purchase_item[:sku])
                    if purchase_item[:producer_id] == ENV['GROUP_ID']
                      item.buy_to_factory(purchase_item[:quantity])
                    else
                      item.buy_to_producer(purchase_item[:producer_id], purchase_item[:quantity], purchase_item[:price], purchase_item[:time]) #TODO
                    end
                  end
                  product.produce(unit_lote)
                  purchase_order.accept_purchase_order
                end
              else
                product.buy_to_factory(difference)
                purchase_order.accept_purchase_order
              end
            else
              purchase_order.reject_purchase_order('Tiempo insuficiente')
            end
          else
            purchase_order.accept_purchase_order
          end
        else
          purchase_order.reject_purchase_order('Precio incorrecto')
        end
      else
        purchase_order.reject_purchase_order('SKU incorrecto')
      end
    else
      purchase_order.reject_purchase_order('Proveedor incorrecto')
    end
  end
end
