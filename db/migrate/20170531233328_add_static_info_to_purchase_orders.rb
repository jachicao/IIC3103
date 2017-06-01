class AddStaticInfoToPurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_orders, :sku, :string
    add_column :purchase_orders, :group_number, :integer
    add_column :purchase_orders, :cuantity, :integer
  end
end
