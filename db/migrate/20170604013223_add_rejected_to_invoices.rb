class AddRejectedToInvoices < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :rejected, :boolean, default: false
  end
end
