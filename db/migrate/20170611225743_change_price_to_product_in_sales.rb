class ChangePriceToProductInSales < ActiveRecord::Migration[5.0]
  def change
    change_column :product_in_sales, :price, :integer, :default => 0
  end
end
