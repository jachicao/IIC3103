class MoveProductsBetweenStoreHousesWorker
  include Sidekiq::Worker

  def perform(from_store_house_id, to_store_house_id, sku, quantity)
    total_moved = 0
    while total_moved < quantity
      quantity_to_move = [quantity - total_moved, 100].min
      products = GetProductStockJob.perform_now(from_store_house_id, sku, quantity_to_move)
      if products != nil
        if products[:body].count > 0
          products[:body].each do |p|
            result = MoveProductInternallyJob.perform_now(p[:_id], from_store_house_id, to_store_house_id)
            if result[:code] == 200
              total_moved += 1
            elsif result[:code] == 400
              break
            elsif result[:code] == 429
              puts 'total left: ' + (quantity - total_moved).to_s
              puts 'sleeping server-rate seconds'
              sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
              break
            end
          end
        else
          break
        end
      else
        puts 'sleeping server-rate seconds'
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      end
      puts 'sleeping 5 seconds'
      sleep(5)
    end
  end
end
