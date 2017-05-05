class CreateTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :transactions do |t|
      t.string :originAcount
      t.string :destinationAcount
      t.decimal :amount

      t.timestamps
    end
  end
end
