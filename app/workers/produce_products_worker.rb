class ProduceProductsWorker < ApplicationWorker
  sidekiq_options queue: 'default'

  def perform(*args)
    # Do something

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

    if StoreHouse.is_dispatching_products
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
            puts 'ProduceProductsWorker: ' + ingredient.item.name.to_s + ' is ready'
          else
            puts 'ProduceProductsWorker: ' + ingredient.item.name.to_s + ' is left: ' + (ingredient.quantity - total).to_s
            ready = false
          end
        end
        if ready and despacho_total_space - despacho_used_space >= space_required - total_in_despacho
          all_in_despacho = true
          pending_product.product.ingredients.each do |ingredient|
            total = 0
            sku = ingredient.item.sku
            ingredient.item.stocks.each do |s|
              if s.store_house.despacho
                total += s.quantity
              end
            end
            quantity_left = ingredient.quantity - total
            if quantity_left > 0
              all_in_despacho = false
              puts 'ProduceProductsWorker: moving ' + ingredient.item.name.to_s + ' to despacho: ' + quantity_left.to_s
              StoreHouse.all.each do |to_store_house|
                if to_store_house.despacho
                  to_store_house_id = to_store_house._id
                  to_total_space = to_store_house.total_space
                  to_used_space = to_store_house.used_space
                  if to_total_space - to_used_space > 0
                    ingredient.item.stocks.each do |s|
                      if s.store_house.despacho
                      else
                        from_store_house_id = s.store_house._id
                        if s.quantity > 0 and to_total_space - to_used_space > 0 and quantity_left > 0
                          limit = [to_total_space - to_used_space, s.quantity, quantity_left, 100].min

                          products = self.get_product_stock(from_store_house_id, sku, limit)
                          if products != nil
                            products[:body].each do |p|
                              product_id = p[:_id]
                              if StoreHouse.can_send_request
                                quantity_left -= 1
                                to_used_space += 1
                                MoveProductToStoreHouseWorker.perform_async(sku, product_id, from_store_house_id, to_store_house_id)
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
          if all_in_despacho
            if pending_product.quantity > 0
              puts 'ProduceProductsWorker: producing ' + pending_product.product.name
              pending_product.update(quantity: pending_product.quantity - 1)
              my_product_in_sale = pending_product.product.get_my_product_sale
              my_product_in_sale.buy_to_factory_async(pending_product.product.lote)
            end
          end
          break
        end
      end
    end
  end
end
