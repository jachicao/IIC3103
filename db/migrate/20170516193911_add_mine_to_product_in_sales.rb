class AddMineToProductInSales < ActiveRecord::Migration[5.0]
  def change
    add_column :product_in_sales, :mine, :boolean
  end
end
