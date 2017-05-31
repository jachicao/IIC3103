class MoveProductsBetweenGroupsWorker
  include Sidekiq::Worker

  def perform(from_store_house_id, to_store_house_id, sku, quantity, po_id, price)
    total_moved = 0
    while total_moved < quantity
      quantity_to_move = [quantity - total_moved, 100].min
      products = GetProductStockJob.perform_now(from_store_house_id, sku, quantity_to_move)
      if products != nil
        products[:body].each do |p|
          result = MoveProductExternallyJob.perform_now(p[:_id], from_store_house_id, to_store_house_id, po_id, price)
          if result[:code] == 200
            total_moved += 1
          elsif result[:code] == 429
            puts 'total left: ' + (quantity - total_moved).to_s
            puts 'sleeping server-rate seconds'
            sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
            break
          end
        end
      end
      puts 'sleeping 5 seconds'
      sleep(5)
    end
    purchase_order = PurchaseOrder.all.find_by(po_id: po_id)
    purchase_order.confirm_dispatched
  end
end
