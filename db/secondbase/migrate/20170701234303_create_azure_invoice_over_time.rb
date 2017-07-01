class CreateAzureInvoiceOverTime < ActiveRecord::Migration[5.0]
  def change
    create_table :azure_invoice_over_times do |t|
      t.references :azure_date, foreign_key: true
      t.references :azure_invoice, foreign_key: true
      t.string :status
    end
  end
end
