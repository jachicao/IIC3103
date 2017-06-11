class AddAnalyzingToPurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_orders, :analyzing, :boolean, default: false
  end
end
