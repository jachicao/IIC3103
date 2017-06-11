class ChangeSendingToPurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    change_column :purchase_orders, :sending, :boolean, :default => false
    change_column :purchase_orders, :dispatched, :boolean, :default => false
  end
end
