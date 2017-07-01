class CreateAzureStoreHouse < ActiveRecord::Migration[5.0]
  def change
    create_table :azure_store_houses do |t|
      t.string :_id
      t.integer :total_space
      t.string :store_type
    end
    add_index :azure_store_houses, :_id
  end
end
