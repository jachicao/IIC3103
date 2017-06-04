class FixClientFromInvoices < ActiveRecord::Migration[5.0]
  def change
    rename_column :invoices, :client, :client_id
    rename_column :invoices, :supplier, :supplier_id
  end
end
