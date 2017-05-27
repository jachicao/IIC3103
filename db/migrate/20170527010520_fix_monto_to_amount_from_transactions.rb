class FixMontoToAmountFromTransactions < ActiveRecord::Migration[5.1]
  def change
    rename_column :transactions, :monto, :amount
  end
end
