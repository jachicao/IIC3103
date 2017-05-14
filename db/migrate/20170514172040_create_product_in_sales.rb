class CreateProductInSales < ActiveRecord::Migration[5.1]
  def change
    create_table :product_in_sales do |t|
      t.references :producer, foreign_key: true
      t.references :product, foreign_key: true
      t.integer :price
      t.decimal :average_time

      t.timestamps
    end
  end
end
