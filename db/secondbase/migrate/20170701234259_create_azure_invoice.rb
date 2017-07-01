class CreateAzureInvoice < ActiveRecord::Migration[5.0]
  def change
    create_table :azure_invoices do |t|
      t.references :azure_purchase_order, foreign_key: true
      t.references :azure_bank_transaction, foreign_key: true
      t.string :_id
      t.string :po_id
      t.string :client
      t.string :supplier
      t.integer :amount
      t.string :bank_id
      t.datetime :created_at
      t.datetime :updated_at
      t.string :status
    end
    add_index :azure_invoices, :_id
  end
end
