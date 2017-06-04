class FixInvoicesColumn < ActiveRecord::Migration[5.0]
  def change
    rename_column :invoices, :total_amount, :amount
  end
end
