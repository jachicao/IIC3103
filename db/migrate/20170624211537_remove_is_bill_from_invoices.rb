class RemoveIsBillFromInvoices < ActiveRecord::Migration[5.0]
  def change
    remove_column :invoices, :is_bill, :boolean
  end
end
