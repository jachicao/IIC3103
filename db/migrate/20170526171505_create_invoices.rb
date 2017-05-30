class CreateInvoices < ActiveRecord::Migration[5.0]
  def change
    create_table :invoices do |t|
      t.string :_id
      t.string :supplier
      t.string :client
      t.integer :total_amount
      t.integer :tax
      t.string :status
      t.string :po_id

      t.timestamps
    end
  end
end
