class CreateStocks < ActiveRecord::Migration[5.0]
  def change
    create_table :stocks do |t|
      t.references :product, foreign_key: true
      t.references :store_house, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
