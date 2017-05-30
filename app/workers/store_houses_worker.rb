class StoreHousesWorker
  include Sidekiq::Worker

  def perform(*args)
    puts 'Cleaning recepcion and pulmon'
    StoreHouse.clean_recepcion
    StoreHouse.clean_pulmon
  end
end
