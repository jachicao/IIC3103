class CreateStoreHouses < ActiveRecord::Migration[5.0]
  def change
    create_table :store_houses do |t|
      t.integer :usedSpace
      t.integer :totalSpace
      t.boolean :reception
      t.boolean :dispatch
      t.boolean :external

      t.timestamps
    end
  end
end
