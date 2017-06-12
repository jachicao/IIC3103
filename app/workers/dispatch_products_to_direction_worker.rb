class DispatchProductsToDirectionWorker < ApplicationWorker
  sidekiq_options queue: 'default'

  def perform(direction, sku, quantity, po_id, price)
    puts 'starting DispatchProductsToDirectionWorker'

    quantity_left = quantity

    store_houses = StoreHouse.all
    despacho_id = nil

    store_houses.each do |store_house|
      if store_house.despacho
        despacho_id = store_house._id
      end
    end

    while quantity_left > 0
      store_houses.each do |store_house|
        if quantity_left > 0
          if store_house.despacho
          else
            used_space = store_house.used_space
            if used_space > 0 and quantity_left > 0
              limit = [quantity_left, used_space, 100].min
              products = self.get_product_stock(store_house._id, sku, limit)
              if products != nil
                products[:body].each do |p|
                  if quantity_left > 0
                    internal_result = MoveProductInternallyJob.perform_now(sku, p[:_id], store_house._id, despacho_id)
                    if internal_result[:code] == 200
                      while true
                        external_result = MoveProductToDirectionWorker.new.perform(sku, p[:_id], despacho_id, direction, price, po_id)
                        if external_result[:code] == 200
                          quantity_left -= 1
                          puts 'DispatchProductsToDirectionWorker: quantity left: ' + quantity_left.to_s
                          break
                        elsif external_result[:code] == 429
                          puts 'DispatchProductsToDirectionWorker: sleeping server-rate seconds'
                          sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
                        end
                      end
                    elsif internal_result[:code] == 429
                      puts 'DispatchProductsToDirectionWorker: sleeping server-rate seconds'
                      sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
                      break
                    else
                      break
                    end
                  end
                end
              else
                puts 'DispatchProductsToDirectionWorker: sleeping server-rate seconds'
                sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
              end
            end
          end
        end
      end
    end
  end
end
