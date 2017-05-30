class AddPaymentDateToInvoices < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :payment_date, :datetime
  end
end
