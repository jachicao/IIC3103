class AddStatusToPurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_orders, :status, :string
  end
end
