class ChangeColumnName < ActiveRecord::Migration[5.0]
  def change
    rename_column :purchase_orders, :cuantity, :quantity
  end
end
