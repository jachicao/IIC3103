class MoveProductsBetweenStoreHousesJob < ApplicationJob
  queue_as :default

  def perform(to_store_house_id, from_store_house_id, sku, quantity)
    total_moved = 0
    while total_moved < quantity
      quantity_to_move = [quantity - total_moved, 100].min
      products = GetProductStockJob.perform_now(from_store_house_id, sku, quantity_to_move)
      if products != nil
        puts products[:body]
        products[:body].each do |p|
          result = MoveProductInternallyJob.perform_now(p[:_id], to_store_house_id, from_store_house_id)
          if result != nil
            if result[:code] == 200
              total_moved += 1
            end
          else
            break
          end
        end
        puts 'sleeping server-rate seconds'
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      else
        puts 'sleeping 5 seconds'
        sleep(5)
      end
    end
  end
end
