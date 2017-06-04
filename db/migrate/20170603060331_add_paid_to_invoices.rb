class AddPaidToInvoices < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :paid, :boolean, default: false
  end
end
