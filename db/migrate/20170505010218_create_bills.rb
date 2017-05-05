class CreateBills < ActiveRecord::Migration[5.1]
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
      t.string :cancellationCause

      t.timestamps
    end
  end
end
