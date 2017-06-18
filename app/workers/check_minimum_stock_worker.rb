class CheckMinimumStockWorker < ApplicationWorker
  sidekiq_options queue: 'default'

  def get_quantity_needed(arr, product, quantity, add)
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
        arr.each do |p|
          if p[:sku] == ingredient.item.sku
            unit_lote = (quantity.to_f / product.lote.to_f).ceil
            self.get_quantity_needed(arr, ingredient.item, unit_lote * ingredient.quantity, true)
          end
        end
      end
    end
  end

  def analyze_quantity_needed(arr, product, quantity_needed)
    sku = product.sku
    arr.each do |p|
      if sku == p[:sku]
        if p[:stock_available] >= quantity_needed
          p[:stock_available] -= quantity_needed
        else
          #p[:stock_available] = 0
          p[:quantity_needed] += quantity_needed
          if product.is_produced_by_me
            if product.ingredients.size > 0
              unit_lote = (quantity_needed.to_f / product.lote.to_f).ceil
              product.ingredients.each do |ingredient|
                self.analyze_quantity_needed(arr, ingredient.item, ingredient.quantity * unit_lote)
              end
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
        products.push({ sku: product.sku, name: product.name, quantity_needed: 0, stock_available: product.stock })
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
                p[:stock_available] += (purchase_order.quantity - purchase_order.server_quantity_dispatched)
              end
            end
          end
        end
      end

      #productos pendientes a fabricar que están listos para fabricar
      PendingProduct.all.each do |pending_product|
        unit_lote = pending_product.quantity
=begin
        pending_product.product.ingredients.each do |ingredient|
          stock_available = 0
          products.each do |p|
            if ingredient.item.sku == p[:sku]
              stock_available = p[:stock_available]
            end
          end
          quantity = (stock_available.to_f / ingredient.quantity.to_f).floor
          unit_lote = [unit_lote, quantity].min
        end
=end
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


      #cantidad requeridas mi para tener minimo 2 lotes
      Product.all.each do |product|
        self.get_quantity_needed(products, product, product.lote * 2, false)
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
                  quantity_to_dispatch = (purchase_order.quantity - purchase_order.server_quantity_dispatched)
                  self.analyze_quantity_needed(products, product, quantity_to_dispatch)
                end
              end
            end
          end
        end
      end

      puts products

      products.each do |p|
        product = Product.find_by(sku: p[:sku])
        difference = [p[:quantity_needed] - p[:stock_available], 5000].min
        if difference > 0
          puts product.name + ' ' + difference.to_s
          product.buy_min_stock(difference)
        end
      end
    end
  end
end