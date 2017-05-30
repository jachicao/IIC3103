class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :sku
      t.string :name
      t.string :product_type
      t.string :unit
      t.integer :unit_cost
      t.integer :lote

      t.timestamps
    end
  end
end
