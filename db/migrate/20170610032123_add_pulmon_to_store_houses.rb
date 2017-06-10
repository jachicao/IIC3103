class AddPulmonToStoreHouses < ActiveRecord::Migration[5.0]
  def change
    add_column :store_houses, :pulmon, :boolean, default: false
  end
end
