class RemoveRejectedToInvoices < ActiveRecord::Migration[5.0]
  def change
    remove_column :invoices, :rejected, :boolean
  end
end
