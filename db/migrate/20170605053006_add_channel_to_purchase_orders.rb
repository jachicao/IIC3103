class AddChannelToPurchaseOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :purchase_orders, :channel, :string
  end
end
