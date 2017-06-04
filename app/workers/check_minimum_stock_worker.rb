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
    my_purchase_orders = PurchaseOrder.get_my_orders
    my_purchase_orders.each do |purchase_order|
      server = PurchaseOrder.get_server_details(purchase_order.po_id)
      body = server[:body].first
      if body[:estado] == 'creada' || body[:estado] == 'aceptada'
        sku = purchase_order.get_product.sku
        quantity = purchase_order.quantity
        my_products.each do |product|
          if sku == product[:sku]
            product[:stock] += quantity
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
    client_purchase_orders = PurchaseOrder.get_client_orders
    client_purchase_orders.each do |purchase_order|
      server = PurchaseOrder.get_server_details(purchase_order.po_id)
      body = server[:body].first
      if body[:estado] == 'aceptada'
        sku = purchase_order.get_product.sku
        my_products.each do |product|
          if sku == product[:sku]
            product[:stock] -= purchase_order.quantity
          end
        end
      end
    end
    my_products.each do |product|
      product[:quantity] = [product[:quantity], 5000].min # maximo 5000 unidades
      product[:stock] = [product[:stock], 0].max
    end

    puts my_products
    my_products.each do |p|
      difference = p[:quantity] - p[:stock]
      if difference > 0
        product = Product.find_by(sku: p[:sku])
        if product.ingredients.size > 0
          puts 'CheckMinimumStockWorker: produciendo ' + difference.to_s + ' de ' + product.name
          unit_lote = (difference.to_f / product.lote.to_f).ceil
          product.ingredients.each do |ingredient|
            quantity = ingredient.quantity * unit_lote - ingredient.item.get_stock_available
            if quantity > 0
              me = false
              ingredient.item.product_in_sales.each do |product_in_sale|
                if product_in_sale.is_mine
                  me = true
                  puts 'CheckMinimumStockWorker: comprando ' + quantity.to_s + ' de ' + ingredient.item.name
                  ingredient.item.buy_to_factory(quantity)
                  break
                end
              end
              if me
              else
                best = ingredient.item.get_best_producer(quantity)
                if best[:success]
                  puts best[:producer_id]
                  puts 'CheckMinimumStockWorker: comprando ' + quantity.to_s + ' de ' + ingredient.item.name
                  ingredient.item.buy_to_producer(best[:producer_id], quantity, best[:price], best[:time]) #TODO
                end
              end
            end
          end
        else
          puts 'CheckMinimumStockWorker: comprando ' + difference.to_s + ' de ' + product.name
          product.buy_to_factory(difference)
        end
      end
    end
  end
end
