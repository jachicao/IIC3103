class ChangeInvoices < ActiveRecord::Migration[5.0]
  def change
    change_table :invoices do |t|
      t.timestamps
    end
  end
end
