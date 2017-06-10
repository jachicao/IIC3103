class AddOtroToStoreHouses < ActiveRecord::Migration[5.0]
  def change
    add_column :store_houses, :otro, :boolean, default: false
  end
end
