class AddTrxIdToInvoices < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :trx_id, :string
  end
end
