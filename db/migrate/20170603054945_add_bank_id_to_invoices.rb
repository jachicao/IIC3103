class AddBankIdToInvoices < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :bank_id, :string
  end
end
