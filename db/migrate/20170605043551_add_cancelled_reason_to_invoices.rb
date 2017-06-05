class AddCancelledReasonToInvoices < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :cancelled_reason, :string
  end
end
