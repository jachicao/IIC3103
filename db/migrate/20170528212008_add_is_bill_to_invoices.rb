class AddIsBillToInvoices < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :is_bill, :boolean, default: false
  end
end
