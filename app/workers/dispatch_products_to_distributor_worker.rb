class DispatchProductsToDistributorWorker
  include Sidekiq::Worker

  def perform(po_id)
    puts 'starting DDispatchProductsToDistributorWorker'
    store_houses = StoreHouse.all
    despacho_id = nil

    store_houses.each do |store_house|
      if store_house.despacho
        despacho_id = store_house._id
      end
    end
    purchase_order = PurchaseOrder.find_by(po_id: po_id)
    quantity_left = purchase_order.quantity - purchase_order.quantity_dispatched
    direction = purchase_order.client_id
    sku = purchase_order.product.sku
    price = purchase_order.unit_price

    while quantity_left > 0
      store_houses.each do |store_house|
        if quantity_left > 0
          if store_house.despacho
          else
            used_space = store_house.used_space
            if used_space > 0 and quantity_left > 0
              limit = [quantity_left, used_space, 100].min
              products = GetProductStockJob.perform_now(store_house._id, sku, limit)
              if products != nil
                products[:body].each do |p|
                  if quantity_left > 0
                    internal_result = MoveProductInternallyJob.perform_now(sku, p[:_id], store_house._id, despacho_id)
                    if internal_result[:code] == 200
                      while true
                        external_result = DispatchProductJob.perform_now(sku, p[:_id], despacho_id, direction, price, po_id)
                        if external_result[:code] == 200
                          quantity_left -= 1
                          purchase_order.update(quantity_dispatched: purchase_order.quantity - quantity_left)
                          puts 'quantity left: ' + quantity_left.to_s
                          break
                        elsif external_result[:code] == 429
                          puts 'DispatchProductsToDistributorWorker: sleeping server-rate seconds'
                          sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
                        end
                      end
                    elsif internal_result[:code] == 429
                      puts 'DispatchProductsToDistributorWorker: sleeping server-rate seconds'
                      sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
                      break
                    else
                      break
                    end
                  end
                end
              else
                puts 'DispatchProductsToDistributorWorker: sleeping server-rate seconds'
                sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
              end
            end
          end
        end
      end
    end
  end
end
