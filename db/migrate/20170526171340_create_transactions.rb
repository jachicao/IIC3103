class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.string :_id
      t.integer :monto
      t.string :origin
      t.string :destination

      t.timestamps
    end
  end
end
