class CheckMinimumStockWorker
  include Sidekiq::Worker

  def get_store_houses
    store_houses = nil
    while store_houses.nil?
      store_houses = StoreHouse.all
      if store_houses.nil?
        puts 'CheckMinimumStockWorker: sleeping server-rate seconds'
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      end
    end
    return store_houses
  end

  def get_stock(store_house_id)
    stock = nil
    while stock.nil?
      stock = StoreHouse.get_stock(store_house_id)
      if stock.nil?
        puts 'CheckMinimumStockWorker: sleeping server-rate seconds'
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      end
    end
    return stock
  end

  def perform(*args)
    if ENV['DOCKER_RUNNING'].nil?
      return
    end
    puts 'starting CheckMinimumStockWorker'
    my_products = []
    Producer.get_me.product_in_sales.each do |product_in_sale|
      my_products.push({ sku: product_in_sale.product.sku, quantity: product_in_sale.product.lote, stock: 0 })
    end
    ingredients = []
    Product.all.each do |product|
      product.ingredients.each do |ingredient|
        ingredients.push(ingredient)
      end
    end
    ingredients.each do |ingredient|
      my_products.each do |product|
        if ingredient.item.sku == product[:sku]
          product[:quantity] += ingredient.quantity
        end
      end
    end

    store_houses = get_store_houses
    store_houses.each do |store_house|
      stock = get_stock(store_house[:_id])
      stock.each do |p|
        my_products.each do |product|
          if p[:sku] == product[:sku]
            product[:stock] += p[:total]
          end
        end
      end
    end

    #ordenes de compra hechas por mi
    PurchaseOrder.all.each do |purchase_order|
      if purchase_order.is_made_by_me
        if purchase_order.status == 'creada' || purchase_order.status == 'aceptada'
          sku = purchase_order.get_product.sku
          quantity = purchase_order.quantity
          my_products.each do |product|
            if sku == product[:sku]
              product[:stock] += quantity
            end
          end
        end
      end
    end

    #ordenes de fabricación hechas por mi
    FactoryOrder.all.each do |factory_order|
      if DateTime.current <= factory_order.available
        my_products.each do |product|
          if factory_order.sku == product[:sku]
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

    #ordenes de compra recibidas
    PurchaseOrder.all.each do |purchase_order|
      if purchase_order.is_made_by_me
      else
        if purchase_order.dispatched
        else
          if purchase_order.status == 'aceptada'
            sku = purchase_order.sku
            my_products.each do |product|
              if sku == product[:sku]
                product[:stock] -= (purchase_order.quantity - purchase_order.quantity_dispatched)
              end
            end
          end
        end
      end
    end

    my_products.each do |product|
      product[:quantity] = [product[:quantity], 5000].min
    end

    my_products.each do |p|
      product = Product.find_by(sku: p[:sku])
      product.analyze_min_stock(my_products, p[:quantity])
    end
  end
end
