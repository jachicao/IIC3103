class AddDispatchedToPurchaseOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :purchase_orders, :dispatched, :boolean
  end
end
