class AddRejectedReasonToPurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_orders, :rejected_reason, :string
  end
end
