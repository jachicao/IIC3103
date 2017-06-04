class AddQuantityDispatchedToPurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_orders, :quantity_dispatched, :integer, default: 0
  end
end
