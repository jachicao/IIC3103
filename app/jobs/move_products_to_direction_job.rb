class MoveProductsToDirectionJob < ApplicationJob
  queue_as :default

  def perform(from_store_house_id, direction, sku, quantity, po_id, price)
    total_moved = 0
    while total_moved < quantity
      quantity_to_move = [quantity - total_moved, 100].min
      products = GetProductStockJob.perform_now(from_store_house_id, sku, quantity_to_move)
      if products != nil
        products[:body].each do |p|
          result = DispatchProductJob.perform_now(p[:_id], from_store_house_id, direction, price, po_id)
          if result[:code] == 200
            total_moved += 1
          elsif result[:code] == 429
            puts 'sleeping server-rate seconds'
            sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
            break
          end
        end
      else
        puts 'sleeping 5 seconds'
        sleep(5)
      end
    end
  end
end
