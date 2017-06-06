class DispatchProductsToGroupWorker
  include Sidekiq::Worker

  def get_store_houses
    store_houses = nil
    while store_houses.nil?
      store_houses = StoreHouse.all
      if store_houses.nil?
        puts 'DispatchProductsToGroupWorker: sleeping server-rate seconds'
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      end
    end
    return store_houses
  end

  def perform(to_store_house_id, po_id)
    puts 'starting DispatchProductsToGroupWorker'
    purchase_order = PurchaseOrder.find_by(po_id: po_id)

    quantity_left = purchase_order.quantity - purchase_order.quantity_dispatched
    price = purchase_order.unit_price
    sku = purchase_order.sku

    store_houses = get_store_houses
    despacho_id = nil

    store_houses.each do |store_house|
      if store_house[:despacho]
        despacho_id = store_house[:_id]
      end
    end

    while quantity_left > 0
      store_houses.each do |store_house|
        if quantity_left > 0
          if store_house[:despacho]
          else
            stock = StoreHouse.get_stock(store_house[:_id])
            if stock != nil
              total_stock = 0
              stock.each do |p|
                if p[:sku] == sku
                  total_stock += p[:total]
                end
              end
              if total_stock > 0 and quantity_left > 0
                limit = [quantity_left, total_stock, 100].min
                products = GetProductStockJob.perform_now(store_house[:_id], sku, limit)
                if products != nil
                  products[:body].each do |p|
                    if quantity_left > 0
                      internal_result = MoveProductInternallyJob.perform_now(p[:_id], store_house[:_id], despacho_id)
                      if internal_result[:code] == 200
                        while true
                          external_result = MoveProductExternallyJob.perform_now(p[:_id], despacho_id, to_store_house_id, po_id, price)
                          if external_result[:code] == 200
                            quantity_left -= 1
                            purchase_order.update(quantity_dispatched: purchase_order.quantity - quantity_left)
                            puts 'quantity left: ' + quantity_left.to_s
                            break
                          elsif external_result[:code] == 429
                            puts 'DispatchProductsToGroupWorker: sleeping server-rate seconds'
                            sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
                          end
                        end
                      elsif internal_result[:code] == 429
                        puts 'DispatchProductsToGroupWorker: sleeping server-rate seconds'
                        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
                        break
                      else
                        break
                      end
                    end
                  end
                else
                  puts 'DispatchProductsToGroupWorker: sleeping server-rate seconds'
                  sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
                end
              end
            else
              puts 'DispatchProductsToGroupWorker: sleeping server-rate seconds'
              sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
            end
          end
        end
      end
    end
    purchase_order.confirm_dispatched
  end
end
