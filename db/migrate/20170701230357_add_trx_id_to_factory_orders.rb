class AddTrxIdToFactoryOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :factory_orders, :trx_id, :string
  end
end
