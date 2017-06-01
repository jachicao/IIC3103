class AddSpreeOrderIdToInvoices < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :spree_order_id, :integer
  end
end
