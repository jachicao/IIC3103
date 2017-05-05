class CreateBills < ActiveRecord::Migration[5.0]
  def change
    create_table :bills do |t|
      t.string :supplier
      t.string :client
      t.integer :grossValue
      t.integer :iva
      t.integer :totalValue
      t.string :paymentStatus
      t.string :pushaseOrderId
      t.datetime :paymentDeadline
      t.string :rejectionCause
      t.string :CancellationCause

      t.timestamps
    end
  end
end
