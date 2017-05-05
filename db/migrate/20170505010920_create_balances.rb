class CreateBalances < ActiveRecord::Migration[5.1]
  def change
    create_table :balances do |t|
      t.string :account
      t.decimal :amount

      t.timestamps
    end
  end
end
