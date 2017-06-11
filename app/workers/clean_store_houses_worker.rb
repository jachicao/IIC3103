class CleanStoreHousesWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'low'

  def get_products(store_house_id, sku, limit)
    products = nil
    while products.nil?
      products = GetProductStockJob.perform_now(store_house_id, sku, limit)
      if products.nil?
        puts 'CleanStoreHousesWorker: sleeping server-rate seconds'
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      end
    end
    return products
  end

  def move_stock
    stock_left = 0
    StoreHouse.all.each do |from_store_house|
      if from_store_house.pulmon or from_store_house.recepcion
        from_used_space = from_store_house.used_space
        if from_used_space > 0
          from_store_house.stocks.each do |from_p|
            from_p_sku = from_p.product.sku
            from_p_total = from_p.quantity
            if from_p_total > 0
              StoreHouse.all.each do |to_store_house|
                to_total_space = to_store_house.total_space
                if to_store_house.otro
                  to_used_space = to_store_house.used_space
                  if to_total_space - to_used_space > 0 and from_used_space > 0 and from_p_total > 0
                    stock_left += [to_total_space - to_used_space, from_p_total].min
                    total_to_move = [to_total_space - to_used_space, from_p_total, 100].min
                    puts 'CleanStoreHousesWorker: Moviendo ' + total_to_move.to_s
                    products = get_products(from_store_house[:_id], from_p_sku, total_to_move)
                    if products[:body].count > 0
                      products[:body].each do |product|
                        if to_total_space - to_used_space > 0 and from_used_space > 0 and from_p_total > 0 and total_to_move > 0
                          result = MoveProductInternallyJob.perform_now(from_p_sku, product[:_id], from_store_house[:_id], to_store_house[:_id])
                          if result[:code] == 200
                            total_to_move -= 1
                            from_p_total -= 1
                            from_used_space -= 1
                            to_used_space += 1
                            stock_left -= 1
                            puts 'CleanStoreHousesWorker: quantity left ' + total_to_move.to_s
                          elsif result[:code] == 429
                            puts 'CleanStoreHousesWorker: sleeping server-rate seconds'
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
    if ENV['DOCKER_RUNNING'].nil?
      return
    end
    if $cleaning_store_houses != nil
      return nil
    end
    $cleaning_store_houses = true
    puts 'starting CleanStoreHousesWorker'
    while true
      if move_stock == true
        break
      end
    end
    $cleaning_store_houses = nil
  end
end
