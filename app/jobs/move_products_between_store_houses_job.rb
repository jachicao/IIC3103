class MoveProductsBetweenStoreHousesJob < ApplicationJob
  queue_as :default

  def get_products(id, sku, limit)
    response = nil
    while response == nil
      response = GetProductStockJob.perform_now(id, sku, limit)
      if response == nil
        sleep(5)
      end
    end
    return response[:body]
  end

  def perform(to_store_house_id, from_store_house_id, sku, quantity)
    $redis.del('get_almacenes')
    $redis.del('get_skus_with_stock:' + to_store_house_id)
    $redis.del('get_skus_with_stock:' + from_store_house_id)
    limit = (quantity.to_f / 100.to_f).ceil
    total_moved = 0
    index = 0
    while index < limit
      quantity_to_move = [quantity - total_moved, 100].min
      products = get_products(from_store_house_id, sku, quantity_to_move)
      products.each do |p|
        MoveProductInternallyJob.perform_later(p[:_id], to_store_house_id, from_store_house_id)
      end
      total_moved += quantity_to_move
      index += 1
    end
  end
end
