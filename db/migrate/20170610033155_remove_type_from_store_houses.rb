class RemoveTypeFromStoreHouses < ActiveRecord::Migration[5.0]
  def change
    remove_column :store_houses, :_type, :string
  end
end
