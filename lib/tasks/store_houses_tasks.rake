namespace :store_houses_tasks do
  desc 'StoreHouses tasks'
  task clean_recepcion_and_pulmon: :environment do
    puts 'cleaning recepcion and pulmon'
    StoreHouse.clean_recepcion
    StoreHouse.clean_pulmon
  end
end