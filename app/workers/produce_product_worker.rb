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
        if pending_product.quantity > 0
        else
          puts 'destroy'
          pending_product.destroy
        end
      end

      PendingProduct.all.each do |pending_product|
        puts 'Checking ' + pending_product.product.name.to_s
        if pending_product.product.ingredients.size > 0
          if pending_product.quantity > 0
            ready = true
            pending_product.purchased_products.each do |purchased_product|
              ingredient_quantity = 0
              pending_product.product.ingredients.each do |ingredient|
                if ingredient.item.sku == purchased_product.product.sku
                  ingredient_quantity = ingredient.quantity
                  break
                end
              end
              total = 0
              all_stock.each do |store_house|
                store_house[:inventario].each do |p|
                  if p[:sku] == purchased_product.product.sku
                    total += p[:total]
                  end
                end
              end
              if total >= ingredient_quantity
                puts purchased_product.product.name.to_s + ' is ready'
              else
                ready = false
                puts purchased_product.product.name.to_s + ' is left: ' + (ingredient_quantity - total).to_s
              end
            end
            if ready
              all_in_despacho = true
              pending_product.purchased_products.each do |purchased_product|
                ingredient_quantity = 0
                pending_product.product.ingredients.each do |ingredient|
                  if ingredient.item.sku == purchased_product.product.sku
                    ingredient_quantity = ingredient.quantity
                    break
                  end
                end
                total_despacho = 0
                all_stock.each do |store_house|
                  store_house[:inventario].each do |p|
                    if p[:sku] == purchased_product.product.sku
                      if store_house[:despacho]
                        total_despacho += p[:total]
                      end
                    end
                  end
                end
                if total_despacho >= ingredient_quantity
                else
                  StoreHouse.move_stock(not_despachos, despachos, purchased_product.product.sku, ingredient_quantity - total_despacho)
                  puts 'move ' + purchased_product.product.name.to_s + ' to despacho: ' + (ingredient_quantity - total_despacho).to_s
                  all_in_despacho = false
                end
              end
              if all_in_despacho and pending_product.quantity > 0
                puts 'producing ' + pending_product.product.name
                pending_product.quantity -= 1
                pending_product.save
                FactoryOrder.make_product(pending_product.product.sku, pending_product.product.lote, pending_product.product.unit_cost)
              end
              break
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
