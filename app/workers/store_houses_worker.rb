class StoreHousesWorker
  include Sidekiq::Worker

  def perform(*args)
    puts 'cleaning'
    StoreHouse.clean_recepcion
    StoreHouse.clean_pulmon
  end
end
