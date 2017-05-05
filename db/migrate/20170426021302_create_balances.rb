class CreateBalances < ActiveRecord::Migration[5.0]
  def change
    create_table :balances do |t|
      t.string :acount
      t.decimal  :amount

      t.timestamps
    end
  end
end
