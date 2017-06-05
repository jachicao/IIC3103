class AddRejectedReasonToInvoices < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :rejected_reason, :string
  end
end
