class AddAnalyzingToInvoices < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :analyzing, :boolean, default: false
  end
end
