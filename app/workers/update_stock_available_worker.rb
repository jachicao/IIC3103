class UpdateStockAvailableWorker
  include Sidekiq::Worker

  def get_store_houses
    store_houses = nil
    while store_houses.nil?
      store_houses = StoreHouse.all
      if store_houses.nil?
        puts 'UpdateStockAvailableWorker: sleeping server-rate seconds'
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
        puts 'UpdateStockAvailableWorker: sleeping server-rate seconds'
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      end
    end
    return stock
  end

  def perform(*args)
    #puts 'starting UpdateStockAvailableWorker'
    my_products = []
    Producer.get_me.product_in_sales.each do |product_in_sale|
      my_products.push({ sku: product_in_sale.product.sku, stock_available: 0, stock: 0 })
    end

    #stock en almacenes
    store_houses = get_store_houses
    store_houses.each do |store_house|
      stock = get_stock(store_house[:_id])
      stock.each do |p|
        my_products.each do |product|
          if p[:sku] == product[:sku]
            product[:stock_available] += p[:total]
            product[:stock] += p[:total]
          end
        end
      end
    end

    #productos pendientes a fabricar
    PendingProduct.all.each do |pending_product|
      pending_product.product.ingredients do |ingredient|
        my_products.each do |product|
          if ingredient.item.sku == product[:sku]
            product[:stock_available] -= ingredient.quantity * pending_product.quantity
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
            product[:stock_available] -= purchase_order.quantity
          end
        end
      end
    end

    my_products.each do |product|
      product[:stock_available] = [product[:stock_available], 0].max
      product[:stock] = [product[:stock], 0].max
    end

    key = 'available_stock'
    $redis.set(key, my_products.to_json)
    $redis.expire(key, ENV['CACHE_EXPIRE_TIME'].to_i.seconds.to_i)
  end
end
