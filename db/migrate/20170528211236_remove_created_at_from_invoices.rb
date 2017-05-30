class RemoveCreatedAtFromInvoices < ActiveRecord::Migration[5.0]
  def change
    remove_column :invoices, :created_at, :datetime
    remove_column :invoices, :updated_at, :datetime
    remove_column :invoices, :status, :string
    remove_column :invoices, :tax, :integer
  end
end
