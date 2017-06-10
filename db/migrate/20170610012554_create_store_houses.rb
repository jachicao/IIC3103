class CreateStoreHouses < ActiveRecord::Migration[5.0]
  def change
    create_table :store_houses do |t|
      t.string :_id
      t.integer :total_space
      t.string :_type

      t.timestamps
    end
    add_index :store_houses, :_id
  end
end
