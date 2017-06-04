class AddIndexToTables < ActiveRecord::Migration[5.0]
  def change
    add_index :invoices, :_id
    add_index :products, :sku
  end
end
