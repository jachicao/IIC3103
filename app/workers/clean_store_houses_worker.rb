class CleanStoreHousesWorker < ApplicationWorker
  sidekiq_options queue: 'default'

  def clean(from_store_house_id, to_store_house_id)
    from_store_house = StoreHouse.find_by(_id: from_store_house_id)
    to_store_house = StoreHouse.find_by(_id: to_store_house_id)
    from_used_space = from_store_house.used_space
    quantity_moved = 0
    if from_used_space > 0
      from_store_house.stocks.each do |from_s|
        from_s_sku = from_s.product.sku
        from_s_total = from_s.quantity
        if from_used_space > 0
          to_total_space = to_store_house.total_space
          to_used_space = to_store_house.used_space
          if to_total_space - to_used_space > 0 and from_used_space > 0 and from_s_total > 0
            total_to_move = [to_total_space - to_used_space, from_s_total, 100].min
            products = self.get_product_stock(from_store_house_id, from_s_sku, total_to_move)
            if products != nil
              products[:body].each do |p|
                product_id = p[:_id]
                if StoreHouse.can_send_request
                  quantity_moved += 1
                  from_used_space -= 1
                  from_s_total -= 1
                  to_used_space += 1
                  MoveProductToStoreHouseWorker.perform_async(from_s_sku, product_id, from_store_house_id, to_store_house_id)
                end
              end
            end
          end
        end
      end
    end
    if quantity_moved > 0
      puts 'CleanStoreHousesWorker: Moviendo ' + quantity_moved.to_s
    end
  end

  def perform(*args)
    if ENV['DOCKER_RUNNING'] != nil
      puts 'Starting CleanStoreHousesWorker'
      StoreHouse.all.each do |from_store_house|
        if from_store_house.recepcion
          from_used_space = from_store_house.used_space
          if from_used_space > 0
            StoreHouse.all.each do |to_store_house|
              if to_store_house.otro and to_store_house.available_space > 0
                self.clean(from_store_house._id, to_store_house._id)
                return
              end
            end
          end
        end
      end
      StoreHouse.all.each do |from_store_house|
        if from_store_house.pulmon
          from_used_space = from_store_house.used_space
          if from_used_space > 0
            StoreHouse.all.each do |to_store_house|
              if to_store_house.recepcion and to_store_house.available_space > 0
                self.clean(from_store_house._id, to_store_house._id)
                return
              end
            end
          end
        end
      end
    end
  end
end
