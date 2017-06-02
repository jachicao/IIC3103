class CacheWorker
  include Sidekiq::Worker

  def get_store_houses
    store_houses = nil
    while store_houses.nil?
      store_houses = StoreHouse.all
      if store_houses.nil?
        puts 'CacheWorker: sleeping server-rate seconds'
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      end
    end
    return store_houses
  end

  def perform(*args)
    store_houses = get_store_houses
    store_houses.each do |store_house|
      StoreHouse.get_stock(store_house[:_id])
    end
    Bank.get_transactions
  end
end
