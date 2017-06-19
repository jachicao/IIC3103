class AddAcceptedToInvoices < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :accepted, :boolean, default: false
  end
end
