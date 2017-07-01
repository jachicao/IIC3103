class CreateAzureProductStockOverTime < ActiveRecord::Migration[5.0]
  def change
    create_table :azure_product_stock_over_times do |t|
      t.references :azure_date, foreign_key: true
      t.references :azure_product, foreign_key: true
      t.integer :stock
      t.integer :stock_available
    end
  end
end
