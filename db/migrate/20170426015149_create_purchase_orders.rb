class CreatePurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :purchase_orders do |t|
      t.string :orderId
      t.string :channel
      t.string :supplier
      t.string :client
      t.string :sku
      t.integer :quantity
      t.integer :dispatchedQuantity
      t.integer :unitPrice
      t.timestamp :deadline
      t.string :state
      t.string :rejectionCause
      t.string :CancellationCause
      t.string :notes
      t.string :billId

      t.timestamps
    end
  end
end
