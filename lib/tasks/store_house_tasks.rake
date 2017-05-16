namespace :store_house_tasks do
  desc 'Clear reception and move from lung store_house'
  task clear_reception_and_lung: :environment do
    puts 'Clear reception and moving from lung'
    StoreHouseController.movementsStoreHouse
  end
end