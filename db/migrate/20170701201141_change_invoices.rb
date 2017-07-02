class ChangeInvoices < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :created_at, :datetime
    add_column :invoices, :updated_at, :datetime
  end
end
