class RemoveStatusFromPurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    remove_column :purchase_orders, :status, :string
  end
end
