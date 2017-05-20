namespace :store_house_tasks do
  desc 'Clear reception and move from lung store_house'
  task clean_recepcion_and_pulmon: :environment do
    puts 'Clear reception and moving from lung'
    StoreHouse.clean_recepcion
    StoreHouse.clean_pulmon
   end
end