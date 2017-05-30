class CreatePendingProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :pending_products do |t|
      t.references :product, foreign_key: true
      t.integer :quantity
      t.integer :lote

      t.timestamps
    end
  end
end
