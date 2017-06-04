class CacheWorker
  include Sidekiq::Worker

  def perform(*args)
    store_houses = StoreHouse.all
    if store_houses != nil
      store_houses.each do |store_house|
        StoreHouse.get_stock(store_house[:_id])
      end
    end
    Bank.get_transactions
  end
end
