class AddDespachoToStoreHouses < ActiveRecord::Migration[5.0]
  def change
    add_column :store_houses, :despacho, :boolean, default: false
  end
end
