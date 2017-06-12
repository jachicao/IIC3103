class UpdateStoreHousesWorker < ApplicationWorker
  sidekiq_options queue: 'critical'

  def perform(*args)
    store_houses_response = self.get_store_houses
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
          StoreHouse.create(
              _id: store_house[:_id],
              total_space: store_house[:totalSpace],
              pulmon: store_house[:pulmon],
              despacho: store_house[:despacho],
              recepcion: store_house[:recepcion],
              otro: ((not store_house[:pulmon]) and (not store_house[:despacho]) and (not store_house[:recepcion])),
          )
        end
      end

      StoreHouse.all.each do |store_house|
        UpdateStoreHouseWorker.perform_async(store_house._id)
      end
    end
  end
end
