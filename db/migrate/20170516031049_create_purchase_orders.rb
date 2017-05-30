class CreatePurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :purchase_orders do |t|
      t.string :po_id
      t.string :payment_method
      t.string :store_reception_id
      t.string :status

      t.timestamps
    end
    add_index :purchase_orders, :po_id
  end
end
