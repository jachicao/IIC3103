class AddReceptionToStoreHouses < ActiveRecord::Migration[5.0]
  def change
    add_column :store_houses, :recepcion, :boolean, default: false
  end
end
