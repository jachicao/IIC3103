class FixMontoToAmmountFromTransactions < ActiveRecord::Migration[5.1]
  def change
    rename_column :transactions, :monto, :ammount
  end
end
