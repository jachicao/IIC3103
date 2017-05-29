class RemoveLoteFromPendingProducts < ActiveRecord::Migration[5.0]
  def change
    remove_column :pending_products, :lote, :integer
  end
end
