class CacheWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'critical'

  def perform(*args)
    store_houses_response = GetStoreHousesJob.perform_now
    if store_houses_response != nil
      server_store_houses = store_houses_response[:body]

      hash_store_house = Hash.new

      server_store_houses.each do |store_house|
        hash_store_house[store_house[:_id]] = store_house
      end

      StoreHouse.all.each do |store_house|
        if hash_store_house[store_house[:_id]].nil?
          store_house.destroy
        end
      end

      server_store_houses.each do |store_house|
        sh = StoreHouse.find_by(_id: store_house[:_id])
        if sh.nil?
          sh = StoreHouse.create(
              _id: store_house[:_id],
              total_space: store_house[:totalSpace],
              pulmon: store_house[:pulmon],
              despacho: store_house[:despacho],
              recepcion: store_house[:recepcion],
              otro: ((not store_house[:pulmon]) and (not store_house[:despacho]) and (not store_house[:recepcion])),
          )
          Product.all.each do |product|
            sh.stocks.create(
                product: product,
                quantity: 0
            )
          end
        end
      end

      server_store_houses.each do |server_store_house|
        counter = 0
        StoreHouse.all.each do |store_house|
          if server_store_house[:_id] == store_house._id
            counter += 1
          end
          if counter > 1
            store_house.destroy
          end
        end
      end

      StoreHouse.all.each do |store_house|
        stock_response = GetProductsWithStockJob.perform_now(store_house._id)
        if stock_response != nil
          stock = stock_response[:body]
          store_house.stocks.each do |s|
            found = false
            stock.each do |p|
              if s.product.sku == p[:_id]
                s.update(quantity: p[:total])
                found = true
              end
            end
            if found
            else
              s.update(quantity: 0)
            end
          end
        end
      end
    end
    #Bank.get_transactions
  end
end
