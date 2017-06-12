class AddServerQuantityDispatchedToPurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_orders, :server_quantity_dispatched, :integer, default: 0
  end
end
