class CreateAzureStoreHouseOverTime < ActiveRecord::Migration[5.0]
  def change
    create_table :azure_store_house_over_times do |t|
      t.references :azure_date, foreign_key: true
      t.references :azure_store_house, foreign_key: true
      t.integer :used_space
      t.integer :available_space
    end
  end
end
