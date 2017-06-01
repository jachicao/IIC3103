class StoreHousesWorker
  include Sidekiq::Worker
  def perform(*args)
    if $cleaning_store_houses != nil
      return nil
    end
    $cleaning_store_houses = true
    puts 'starting StoreHousesWorker'

    store_houses = nil
    while store_houses.nil?
      store_houses = StoreHouse.all
      if store_houses.nil?
        puts 'StoreHousesWorker: sleeping server-rate seconds'
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      end
    end
    store_houses.each do |from_store_house|
      if from_store_house[:pulmon] || from_store_house[:recepcion]
        from_stock = nil
        while from_stock.nil?
          from_stock = StoreHouse.get_stock(from_store_house[:_id])
          if from_stock.nil?
            puts 'StoreHousesWorker: sleeping server-rate seconds'
            sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
          end
        end
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
                if to_store_house[:despacho] or (not to_store_house[:pulmon] and not to_store_house[:recepcion] and not to_store_house[:despacho])
                  to_stock = nil
                  while to_stock.nil?
                    to_stock = StoreHouse.get_stock(to_store_house[:_id])
                    if to_stock.nil?
                      puts 'StoreHousesWorker: sleeping server-rate seconds'
                      sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
                    end
                  end
                  to_used_space = 0
                  to_stock.each do |to_p|
                    to_used_space += to_p[:total]
                  end
                  if to_total_space - to_used_space > 0 and from_used_space > 0 and from_p_total > 0
                    total_to_move = [to_total_space - to_used_space, from_p_total].min
                    puts 'total a mover'
                    puts total_to_move.to_s
                    while total_to_move > 0
                      limit = [total_to_move, 100].min
                      products = nil
                      while products.nil?
                        products = GetProductStockJob.perform_now(from_store_house[:_id], from_p_sku, limit)
                        if products.nil?
                          puts 'StoreHousesWorker: sleeping server-rate seconds'
                          sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
                        end
                      end
                      if products[:body].count > 0
                        products[:body].each do |product|
                          if to_total_space - to_used_space > 0 and from_used_space > 0 and from_p_total > 0
                            result = MoveProductInternallyJob.perform_now(product[:_id], from_store_house[:_id], to_store_house[:_id])
                            if result[:code] == 200
                              total_to_move -= 1
                              from_p_total -= 1
                              from_used_space -= 1
                              to_used_space += 1
                              puts 'quantity left: ' + total_to_move.to_s
                            elsif result[:code] == 429
                              puts 'StoreHousesWorker: sleeping server-rate seconds'
                              sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
                            else
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
    end
    $cleaning_store_houses = nil
  end
end
