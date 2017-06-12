class CheckMinimumStockWorker < ApplicationWorker
  sidekiq_options queue: 'low'

  def perform(*args)
    if ENV['DOCKER_RUNNING'] != nil
      puts 'starting CheckMinimumStockWorker'
      my_products = []
      Producer.get_me.product_in_sales.each do |product_in_sale|
        my_products.push({ sku: product_in_sale.product.sku, quantity: product_in_sale.product.lote, stock: 0 })
      end

      Product.all.each do |product|
        product.ingredients.each do |ingredient|
          my_products.each do |p|
            if ingredient.item.sku == p[:sku]
              p[:quantity] += ingredient.quantity
            end
          end
        end
      end

      StoreHouse.all.each do |store_house|
        store_house.stocks.each do |s|
          my_products.each do |product|
            if s.product.sku == product[:sku]
              product[:stock] += s.quantity
            end
          end
        end
      end

      #ordenes de compra
      PurchaseOrder.all.each do |purchase_order|
        if purchase_order.is_made_by_me
          if purchase_order.is_created || purchase_order.is_accepted
            sku = purchase_order.product.sku
            quantity = purchase_order.quantity
            my_products.each do |product|
              if sku == product[:sku]
                product[:stock] += quantity
              end
            end
          end
        else
          if purchase_order.is_dispatched
          else
            if purchase_order.is_accepted
              sku = purchase_order.product.sku
              my_products.each do |product|
                if sku == product[:sku]
                  product[:stock] -= (purchase_order.quantity - purchase_order.server_quantity_dispatched)
                end
              end
            end
          end
        end
      end

      #ordenes de fabricación hechas por mi
      FactoryOrder.all.each do |factory_order|
        if DateTime.current <= factory_order.available
          my_products.each do |product|
            if factory_order.product.sku == product[:sku]
              product[:stock] += factory_order.quantity
            end
          end
        end
      end

      #productos pendientes a fabricar
      PendingProduct.all.each do |pending_product|
        my_products.each do |product|
          if pending_product.product.sku == product[:sku]
            product[:stock] += pending_product.product.lote * pending_product.quantity
          end
        end
        pending_product.product.ingredients do |ingredient|
          my_products.each do |product|
            if ingredient.item.sku == product[:sku]
              product[:stock] -= ingredient.quantity * pending_product.quantity
            end
          end
        end
      end

      puts my_products

      my_products.each do |p|
        product = Product.find_by(sku: p[:sku])
        product.analyze_min_stock(my_products, p[:quantity])
      end
    end
  end
end
