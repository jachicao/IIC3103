class CreatePurchasedProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :purchased_products do |t|
      t.references :product, foreign_key: true
      t.references :producer, foreign_key: true
      t.references :pending_product, foreign_key: true
      t.integer :lote
      t.integer :quantity
      t.decimal :time
      t.boolean :order_sent, default: false
      t.string :po_id

      t.timestamps
    end
  end
end
