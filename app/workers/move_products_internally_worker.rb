class MoveProductsInternallyWorker < ApplicationWorker
  sidekiq_options queue: 'low'

  def perform(from_store_house_id, to_store_house_id, sku, quantity)
    from_store_house = StoreHouse.find_by(_id: from_store_house_id)
    to_store_house = StoreHouse.find_by(_id: to_store_house_id)
    to_available_space = to_store_house.available_space
    if to_available_space > 0
      from_store_house.stocks.each do |s|
        if s.product.sku == sku and s.quantity > 0 and quantity > 0
          limit = [to_available_space, s.quantity, quantity, 200].min
          products = self.get_product_stock(from_store_house_id, sku, limit)
          if products != nil
            products[:body].each do |product|
              product_id = product[:_id]
              if StoreHouse.can_send_request
                result = MoveProductToStoreHouseWorker.new.perform(sku, product_id, from_store_house_id, to_store_house_id)
                if result[:code] == 200
                  quantity -= 1
                  puts 'MoveProductsInternallyWorker: quantity left ' + quantity.to_s
                  #break
                else
                  break
                end
              end
            end
          end
        end
      end
    end
    if quantity > 0
      MoveProductsInternallyWorker.perform_in((ENV['SERVER_RATE_LIMIT_TIME'].to_i * 1).seconds, from_store_house_id, to_store_house_id, sku, quantity)
    end
  end
end
