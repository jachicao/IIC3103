class MoveProductsInternallyWorker
  include Sidekiq::Worker

  def get_stock(id)
    stock = nil
    while stock.nil?
      stock = StoreHouse.get_stock(id)
      if stock.nil?
        puts 'MoveProductsInternallyWorker: sleeping server-rate seconds'
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      end
    end
    return stock
  end

  def get_products(id, sku, limit)
    products = nil
    while products.nil?
      products = GetProductStockJob.perform_now(id, sku, limit)
      if products.nil?
        puts 'MoveProductsInternallyWorker: sleeping server-rate seconds'
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      end
    end
    return products
  end

  def move_stock(from_store_houses, to_store_houses, sku, quantity)
    quantity_left = quantity
    from_store_houses.each do |from_store_house|
      from_id = from_store_house['_id']
      from_stock = get_stock(from_id)
      from_stock.each do |from_p|
        from_p_sku = from_p[:sku]
        from_p_total = from_p[:total]
        if from_p_total > 0 and from_p_sku == sku
          to_store_houses.each do |to_store_house|
            to_total_space = to_store_house['totalSpace']
            to_used_space = 0
            to_id = to_store_house['_id']
            to_stock = get_stock(to_id)
            to_stock.each do |to_p|
              to_used_space += to_p[:total]
            end
            if to_total_space - to_used_space > 0 and from_p_total > 0 and quantity_left > 0
              total_to_move = [to_total_space - to_used_space, from_p_total, quantity_left, 100].min
              puts 'MoveProductsInternallyWorker: Moviendo ' + total_to_move.to_s
              products = get_products(from_id, from_p_sku, total_to_move)
              if products[:body].count > 0
                products[:body].each do |product|
                  if to_total_space - to_used_space > 0 and from_p_total > 0 and total_to_move > 0 and quantity_left > 0
                    result = MoveProductInternallyJob.perform_now(product[:_id], from_id, to_id)
                    if result[:code] == 200
                      total_to_move -= 1
                      from_p_total -= 1
                      to_used_space += 1
                      quantity_left -= 1
                      puts 'MoveProductsInternallyWorker: quantity left ' + total_to_move.to_s
                    elsif result[:code] == 429
                      puts 'MoveProductsInternallyWorker: sleeping server-rate seconds'
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
    return quantity_left
  end



  def perform(from_store_houses, to_store_houses, sku, quantity)
    puts 'starting MoveProductsInternallyWorker'
    new_quantity = move_stock(from_store_houses, to_store_houses, sku, quantity)
    if new_quantity > 0
      MoveProductsInternallyWorker.perform_async(from_store_houses, to_store_houses, sku, new_quantity)
    end
  end
end
