class AddSendingToPurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_orders, :sending, :boolean
  end
end
