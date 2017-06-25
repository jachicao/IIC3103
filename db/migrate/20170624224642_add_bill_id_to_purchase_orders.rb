class AddBillIdToPurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_orders, :bill_id, :string
  end
end
