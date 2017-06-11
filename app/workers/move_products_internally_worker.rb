class MoveProductsInternallyWorker
  include Sidekiq::Worker

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

  def perform(from_store_house_id, to_store_house_id, sku, quantity)
    from_store_house = StoreHouse.find_by(_id: from_store_house_id)
    to_store_house = StoreHouse.find_by(_id: to_store_house_id)
    to_available_space = to_store_house.available_space
    if to_available_space > 0
      from_store_house.stocks.each do |s|
        if s.product.sku == sku and s.quantity > 0
          limit = [to_available_space, s.quantity, quantity, 100].min
          products = get_products(from_store_house_id, sku, limit)
          products[:body].each do |product|
            result = MoveProductInternallyJob.perform_now(sku, product[:_id], from_store_house_id, to_store_house_id)
            if result[:code] == 200
              quantity -= 1
              puts 'MoveProductsInternallyWorker: quantity left ' + quantity.to_s
              #break
            elsif result[:code] == 429
              puts 'MoveProductsInternallyWorker: sleeping server-rate seconds'
              sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
            else
              puts result
            end
          end
        end
      end
    end
    if quantity > 0
      MoveProductsInternallyWorker.perform_async(from_store_house_id, to_store_house_id, sku, quantity)
    end
  end
end
