class StoreHousesWorker
  include Sidekiq::Worker

  def get_store_houses
    store_houses = nil
    while store_houses.nil?
      store_houses = StoreHouse.all
      if store_houses.nil?
        puts 'StoreHousesWorker: sleeping server-rate seconds'
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      end
    end
    return store_houses
  end

  def get_stock(store_house)
    stock = nil
    while stock.nil?
      stock = StoreHouse.get_stock(store_house[:_id])
      if stock.nil?
        puts 'StoreHousesWorker: sleeping server-rate seconds'
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      end
    end
    return stock
  end

  def get_products(store_house, sku, limit)
    products = nil
    while products.nil?
      products = GetProductStockJob.perform_now(store_house[:_id], sku, limit)
      if products.nil?
        puts 'StoreHousesWorker: sleeping server-rate seconds'
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      end
    end
    return products
  end

  def move_stock(store_houses)
    stock_left = 0
    store_houses.each do |from_store_house|
      if from_store_house[:pulmon] or from_store_house[:recepcion]
        from_stock = get_stock(from_store_house)
        from_used_space = 0
        from_stock.each do |from_p|
          from_used_space += from_p[:total]
        end
        if from_used_space > 0
          from_stock.each do |from_p|
            from_p_sku = from_p[:sku]
            from_p_total = from_p[:total]
            if from_p_total > 0
              store_houses.each do |to_store_house|
                to_total_space = to_store_house[:totalSpace]
                if (not to_store_house[:pulmon] and not to_store_house[:recepcion] and not to_store_house[:despacho])
                  to_used_space = 0
                  to_stock = get_stock(to_store_house)
                  to_stock.each do |to_p|
                    to_used_space += to_p[:total]
                  end
                  if to_total_space - to_used_space > 0 and from_used_space > 0 and from_p_total > 0
                    total_to_move = [to_total_space - to_used_space, from_p_total, 100].min
                    stock_left = total_to_move
                    puts 'Moviendo ' + total_to_move.to_s
                    products = get_products(from_store_house, from_p_sku, total_to_move)
                    if products[:body].count > 0
                      products[:body].each do |product|
                        if to_total_space - to_used_space > 0 and from_used_space > 0 and from_p_total > 0 and total_to_move > 0
                          result = MoveProductInternallyJob.perform_now(product[:_id], from_store_house[:_id], to_store_house[:_id])
                          if result[:code] == 200
                            total_to_move -= 1
                            from_p_total -= 1
                            from_used_space -= 1
                            to_used_space += 1
                            stock_left -= 1
                            puts 'quantity left: ' + total_to_move.to_s
                          elsif result[:code] == 429
                            puts 'StoreHousesWorker: sleeping server-rate seconds'
                            sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
                          else
                            puts result
                            break
                          end
                        end
                      end
                    else
                      break
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    return stock_left <= 0
  end

  def perform(*args)
    if $cleaning_store_houses != nil
      return nil
    end
    $cleaning_store_houses = true
    puts 'starting StoreHousesWorker'
    store_houses = get_store_houses
    while true
      if move_stock(store_houses) == true
        break
      end
    end
    $cleaning_store_houses = nil
  end
end
