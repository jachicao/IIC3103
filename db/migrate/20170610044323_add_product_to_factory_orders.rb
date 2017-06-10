class AddProductToFactoryOrders < ActiveRecord::Migration[5.0]
  def change
    add_reference :factory_orders, :product, foreign_key: true
  end
end
