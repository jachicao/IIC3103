class RemoveSkuToPurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    remove_column :purchase_orders, :sku, :string
  end
end
