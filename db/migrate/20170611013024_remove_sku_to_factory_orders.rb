class RemoveSkuToFactoryOrders < ActiveRecord::Migration[5.0]
  def change
    remove_column :factory_orders, :sku, :string
  end
end
