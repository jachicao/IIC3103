class CheckMinimumStockWorker < ApplicationWorker
  sidekiq_options queue: 'default'

  def set_quantity(arr, product, quantity, add)
    is_produced_by_me = product.is_produced_by_me
    if is_produced_by_me or add
      arr.each do |p|
        if p[:sku] == product.sku
          p[:quantity_needed] += quantity
        end
      end
    end
    if is_produced_by_me
      product.ingredients.each do |ingredient|
        unit_lote = (quantity.to_f / product.lote.to_f).ceil
        self.set_quantity(arr, ingredient.item, unit_lote * ingredient.quantity, true)
      end
    end
  end

  def perform(*args)
    if ENV['DOCKER_RUNNING'] != nil
      puts 'starting CheckMinimumStockWorker'

      products = []
      Product.all.each do |product|
        products.push({sku: product.sku, name: product.name, quantity_needed: 0, stock_available: product.stock })
      end

      #cantidad requerida para tener minimo
      Product.all.each do |product|
        self.set_quantity(products, product, 2500, false)
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

      #ordenes de compra aceptadas por otros
      PurchaseOrder.all.each do |purchase_order|
        if purchase_order.is_made_by_me
          if purchase_order.is_created or purchase_order.is_accepted
            sku = purchase_order.product.sku
            products.each do |p|
              if sku == p[:sku]
                p[:stock_available] += (purchase_order.quantity - purchase_order.quantity_dispatched)
              end
            end
          end
        end
      end

      #productos pendientes a fabricar que están listos para fabricar
      PendingProduct.all.each do |pending_product|
        unit_lote = pending_product.quantity
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


      #ordenes de compra hechas por otros
      ordered = PurchaseOrder.all.order(delivery_date: :asc)
      ordered.each do |purchase_order|
        if purchase_order.is_made_by_me
        else
          if purchase_order.is_dispatched
          else
            if purchase_order.is_accepted
              product = purchase_order.product
              sku = product.sku
              products.each do |p|
                if sku == p[:sku]
                  quantity_to_dispatch = (purchase_order.quantity - purchase_order.quantity_dispatched)
                  p[:stock_available] -= quantity_to_dispatch
                end
              end
            end
          end
        end
      end

      puts products

      products.each do |p|
        product = Product.find_by(sku: p[:sku])
        p[:stock_available] = [p[:stock_available], 5000].min
        p[:quantity_needed] = [p[:quantity_needed], 5000].min
        difference = [p[:quantity_needed] - p[:stock_available], 5000].min
        if difference > 0
          puts product.name + ' ' + difference.to_s
          product.buy_min_stock(difference)
        end
      end
    end
  end
end