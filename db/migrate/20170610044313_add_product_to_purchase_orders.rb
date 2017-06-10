class AddProductToPurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    add_reference :purchase_orders, :product, foreign_key: true
  end
end
