class CreateBankTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :bank_transactions do |t|
      t.string :_id
      t.string :from
      t.string :to
      t.integer :amount

      t.timestamps
    end
    add_index :bank_transactions, :_id
  end
end
