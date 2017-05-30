class RemoveLoteFromPurchasedProducts < ActiveRecord::Migration[5.0]
  def change
    remove_column :purchased_products, :lote, :integer
    remove_column :purchased_products, :quantity, :integer
    remove_column :purchased_products, :produce_time, :decimal
    remove_column :purchased_products, :order_sent, :boolean
  end
end
