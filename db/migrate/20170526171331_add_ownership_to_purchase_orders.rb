class AddOwnershipToPurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_orders, :own, :boolean
  end
end
