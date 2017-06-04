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
      product_in_sale = ProductInSale.get_my_product_in_sale(purchase_order.sku)
      if product_in_sale != nil
        if purchase_order.unit_price >= product_in_sale.price
          product = product_in_sale.product
          quantity = purchase_order.quantity
          if product.ingredients.size > 0
            analysis = get_ingredients_analysis(product.sku, quantity)
            if analysis[:success]
              time = analysis[:time]
              if time > 0
                if (DateTime.current + time.to_f.hours) <= purchase_order.delivery_date
                  product.purchase_ingredients(analysis[:purchase_ingredients])
                  product.produce(analysis[:quantity])
                  purchase_order.accept_purchase_order
                else
                  purchase_order.reject_purchase_order('Tiempo insuficiente')
                end
              else
                purchase_order.accept_purchase_order
              end
            else
              purchase_order.reject_purchase_order('Tiempo insuficiente')
            end
          else
            analysis = get_factory_analysis(product.sku, quantity)
            if analysis[:success]
              time = analysis[:time]
              if time > 0
                if (DateTime.current + time.to_f.hours) <= purchase_order.delivery_date
                  product.buy_to_factory(analysis[:quantity])
                  purchase_order.accept_purchase_order
                else
                  purchase_order.reject_purchase_order('Tiempo insuficiente')
                end
              else
                purchase_order.accept_purchase_order
              end
            else
              purchase_order.reject_purchase_order('Tiempo insuficiente')
            end
          end
        else
          purchase_order.reject_purchase_order('Precio incorrecto')
        end
      else
        purchase_order.reject_purchase_order('SKU incorrecto')
      end
    else
      purchase_order.reject_purchase_order('proveedor incorrecto')
    end
  end
end
