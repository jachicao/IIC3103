class CacheWorker
  include Sidekiq::Worker

  def get_store_houses
    response = nil
    while response.nil?
      response = GetStoreHousesJob.perform_now
      if response.nil?
        puts 'CacheWorker: sleeping server-rate seconds'
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      end
    end
    return response[:body]
  end

  def get_stock(store_house_id)
    response = nil
    while response.nil?
      response = GetProductsWithStockJob.perform_now(store_house_id)
      if response.nil?
        puts 'CacheWorker: sleeping server-rate seconds'
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      end
    end
    return response[:body]
  end

  def perform(*args)

    server_store_houses = get_store_houses

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
      stock = get_stock(store_house._id)
      stock.each do |p|
        store_house.stocks.each do |s|
          if s.product.sku == p[:_id]
            s.update(quantity: p[:total])
          end
        end
      end
    end
    Bank.get_transactions
  end
end
