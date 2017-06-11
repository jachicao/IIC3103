class AddStockToProductInSales < ActiveRecord::Migration[5.0]
  def change
    add_column :product_in_sales, :stock, :integer, default: 0
  end
end
