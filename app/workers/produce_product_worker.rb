class ProduceProductWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'low'

  def get_products(id, sku, limit)
    products = nil
    while products.nil?
      products = GetProductStockJob.perform_now(id, sku, limit)
      if products.nil?
        puts 'ProduceProductWorker: sleeping server-rate seconds'
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      end
    end
    return products
  end

  def perform(*args)
    # Do something

    if $checking_items_to_produce != nil
      return nil
    end

    if $moving_products_to_produce != nil
      return nil
    end

    PendingProduct.all.each do |pending_product|
      if pending_product.quantity > 0
      else
        puts 'destroy'
        pending_product.destroy
      end
    end
    if PendingProduct.all.size > 0
    else
      return nil
    end

    puts 'Checking items to produce'

    despacho_total_space = 0
    despacho_used_space = 0
    StoreHouse.all.each do |despacho_store_house|
      if despacho_store_house.despacho
        despacho_total_space = despacho_store_house.total_space
        despacho_used_space = despacho_store_house.used_space
      end
    end

    $checking_items_to_produce = true

    PendingProduct.all.each do |pending_product|
      puts 'Trying to produce ' + pending_product.product.name.to_s
      if pending_product.quantity > 0
        ready = true
        space_required = 0
        total_in_despacho = 0
        pending_product.product.ingredients.each do |ingredient|
          space_required += ingredient.quantity
          total = 0
          ingredient.item.stocks.each do |s|
            total += s.quantity
            if s.store_house.despacho
              total_in_despacho += s.quantity
            end
          end
          if total >= ingredient.quantity
            puts 'ProduceProductWorker: ' + ingredient.item.name.to_s + ' is ready'
          else
            puts 'ProduceProductWorker: ' + ingredient.item.name.to_s + ' is left: ' + (ingredient.quantity - total).to_s
            ready = false
          end
        end
        if ready and despacho_total_space - despacho_used_space >= space_required - total_in_despacho
          pending_product.product.ingredients.each do |ingredient|
            total = 0
            ingredient.item.stocks.each do |s|
              if s.store_house.despacho
                total += s.quantity
              end
            end
            total_to_move = ingredient.quantity - total
            if total_to_move > 0
              $moving_products_to_produce = true
              quantity_left = total_to_move
              puts 'ProduceProductWorker: moving ' + ingredient.item.name.to_s + ' to despacho: ' + quantity_left.to_s
              sku = ingredient.item.sku
              StoreHouse.all.each do |to_store_house|
                if to_store_house.despacho
                  to_total_space = to_store_house.total_space
                  if to_total_space - to_store_house.used_space > 0
                    while quantity_left > 0
                      StoreHouse.all.each do |from_store_house|
                        if from_store_house.despacho
                        else
                          from_store_house.stocks.each do |s|
                            if s.product.sku == sku and to_total_space - to_store_house.used_space > 0 and s.quantity > 0 and quantity_left > 0
                              limit = [to_total_space - to_store_house.used_space, s.quantity, quantity_left, 100].min
                              products = get_products(from_store_house._id, sku, limit)
                              products[:body].each do |product|
                                result = MoveProductInternallyJob.perform_now(sku, product[:_id], from_store_house._id, to_store_house._id)
                                if result[:code] == 200
                                  quantity_left -= 1
                                  puts 'ProduceProductWorker: quantity left ' + quantity_left.to_s
                                elsif result[:code] == 429
                                  puts 'ProduceProductWorker: sleeping server-rate seconds'
                                  sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
                                else
                                  puts result
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
            end
          end
          if pending_product.quantity > 0
            puts 'ProduceProductWorker: producing ' + pending_product.product.name
            pending_product.update(quantity: pending_product.quantity - 1)
            FactoryOrder.make_product(pending_product.product.sku, pending_product.product.lote, pending_product.product.unit_cost)
            if pending_product.quantity <= 0
              pending_product.destroy
            end
          end
          $moving_products_to_produce = nil
          break
        end
      end
    end
    $checking_items_to_produce = nil
  end
end
