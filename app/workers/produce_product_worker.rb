class ProduceProductWorker
  include Sidekiq::Worker

  def perform(*args)
    # Do something
    puts 'Checking items to produce'
    if PendingProduct.all.size > 0
      all_stock = StoreHouse.all_stock
      if all_stock.nil?
        return nil
      end
      despachos = []
      not_despachos = []
      all_stock.each do |store_house|
        if store_house[:despacho]
          despachos.push(store_house)
        else
          not_despachos.push(store_house)
        end
      end
      PendingProduct.all.each do |pending_product|
        order_sent = true
        puts 'Checking ' + pending_product.product.name
        pending_product.purchased_products.each do |purchased_product|
          if purchased_product.order_sent
          else
            purchased_product.send_order
            order_sent = false
          end
        end
        if order_sent
          if pending_product.product.ingredients.size > 0
            if pending_product.quantity > 0
              ready = true
              pending_product.purchased_products.each do |purchased_product|
                if purchased_product.quantity > 0
                  total_not_despacho = 0
                  total_despacho = 0
                  all_stock.each do |store_house|
                    store_house[:inventario].each do |p|
                      if p[:sku] == purchased_product.product.sku
                        if store_house[:despacho]
                          total_despacho += p[:total]
                        else
                          total_not_despacho += p[:total]
                        end
                      end
                    end
                  end
                  if total_not_despacho + total_despacho >= purchased_product.lote
                    if total_despacho >= purchased_product.lote
                      ready = true
                      puts  purchased_product.product.name + ' is ready'
                    else
                      ready = false
                      StoreHouse.move_stock(not_despachos, despachos, purchased_product.sku, purchased_product.lote - total_despacho)
                      puts 'move ' + purchased_product.product.name + ' to despacho'
                    end
                  else
                    ready = false
                    puts purchased_product.product.name + ' is left'
                  end
                end
              end
              if ready
                puts 'producing ' + pending_product.product.name
                BuyFactoryProductsJob.perform_later(pending_product.product.sku, pending_product.product.lote, pending_product.product.unit_cost)
                pending_product.purchased_products.each do |purchased_product|
                  purchased_product.quantity -= 1
                  purchased_product.save
                end
                pending_product.quantity -= 1
                pending_product.save
              end
            else
              puts 'destroy'
              pending_product.destroy
            end
          else
            if pending_product.quantity > 0
              ready = true
              pending_product.purchased_products.each do |purchased_product|
                total = 0
                all_stock.each do |store_house|
                  store_house[:inventario].each do |p|
                    if p[:sku] == purchased_product.product.sku
                      total += p[:total]
                    end
                  end
                end
                if total >= purchased_product.lote
                else
                  ready = false
                end
              end
              if ready
                puts pending_product.product.name + ' is in stock'
                pending_product.purchased_products.each do |purchased_product|
                  purchased_product.quantity -= 1
                  purchased_product.save
                end
                pending_product.quantity -= 1
                pending_product.save
              end
            else
              puts 'destroy'
              pending_product.destroy
            end
          end
        end
      end
    end
  end
end
