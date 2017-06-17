class CheckMinimumStockWorker < ApplicationWorker
  sidekiq_options queue: 'low'

  def get_quantity_needed(arr, product)
    if product.is_produced_by_me
      product.ingredients.each do |ingredient|
        arr.each do |p|
          if p[:sku] == ingredient.item.sku
            p[:quantity_needed] += ingredient.quantity
            self.get_quantity_needed(arr, ingredient.item)
          end
        end
      end
    else
      product.ingredients.each do |ingredient|
        if ingredient.item.is_produced_by_me
          arr.each do |p|
            if p[:sku] == ingredient.item.sku
              p[:quantity_needed] += ingredient.quantity
              self.get_quantity_needed(arr, ingredient.item)
            end
          end
        end
      end
    end
  end

  def perform(*args)
    if ENV['DOCKER_RUNNING'] != nil
      puts 'starting CheckMinimumStockWorker'

      products = []
      Product.all.each do |product|
        products.push({ sku: product.sku, quantity_needed: 0, stock_available: product.stock })
      end

      Product.all.each do |product|
        self.get_quantity_needed(products, product)
      end

      Product.all.each do |product|
        if product.is_produced_by_me
          products.each do |p|
            if p[:sku] == product.sku
              p[:quantity_needed] = [p[:quantity_needed], product.lote].max
            end
          end
        end
      end

      #ordenes de fabricación hechas por mi
      FactoryOrder.all.each do |factory_order|
        if DateTime.current <= factory_order.available
          products.each do |p|
            if factory_order.product.sku == p[:sku]
              p[:stock_available] += factory_order.quantity
            end
          end
        end
      end

      #productos pendientes a fabricar
      PendingProduct.all.each do |pending_product|
        unit_lote = pending_product.quantity
        pending_product.product.ingredients.each do |ingredient|
          quantity = (ingredient.item.stock.to_f / (pending_product.quantity.to_f * ingredient.quantity.to_f)).floor
          unit_lote = [unit_lote, quantity].min
        end
        products.each do |p|
          if pending_product.product.sku == p[:sku]
            p[:stock_available] += pending_product.product.lote * unit_lote
          end
        end
        pending_product.product.ingredients.each do |ingredient|
          products.each do |p|
            if ingredient.item.sku == p[:sku]
              p[:stock_available] -= ingredient.quantity * unit_lote
            end
          end
        end
      end


      #ordenes de compra
      PurchaseOrder.all.each do |purchase_order|
        if purchase_order.is_made_by_me
          if purchase_order.is_created or purchase_order.is_accepted
            sku = purchase_order.product.sku
            products.each do |p|
              if sku == p[:sku]
                p[:stock_available] += (purchase_order.quantity - purchase_order.server_quantity_dispatched)
              end
            end
          end
        else
          if purchase_order.is_dispatched
          else
            if purchase_order.is_accepted
              product = purchase_order.product
              sku = product.sku
              products.each do |p|
                if sku == p[:sku]
                  p[:stock_available] -= (purchase_order.quantity - purchase_order.server_quantity_dispatched)
                end
              end
            end
          end
        end
      end

      puts products

      products.each do |p|
        product = Product.find_by(sku: p[:sku])
        product.analyze_min_stock(products, p[:quantity_needed])
      end
    end
  end
end