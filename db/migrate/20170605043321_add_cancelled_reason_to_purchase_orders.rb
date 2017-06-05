class AddCancelledReasonToPurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_orders, :cancelled_reason, :string
  end
end
