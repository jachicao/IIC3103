class RemoveGroupNumberFromPurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    remove_column :purchase_orders, :group_number, :integer
    add_column :purchase_orders, :client_id, :string
    add_column :purchase_orders, :supplier_id, :string
    add_column :purchase_orders, :unit_price, :integer
    add_column :purchase_orders, :delivery_date, :datetime
  end
end
