class CreateAzureProduct < ActiveRecord::Migration[5.0]
  def change
    create_table :azure_products do |t|
      t.string :sku
      t.string :name
      t.string :product_type
      t.string :unit
      t.integer :unit_cost
      t.integer :stock
      t.integer :stock_available
    end
    add_index :azure_products, :sku
  end
end
