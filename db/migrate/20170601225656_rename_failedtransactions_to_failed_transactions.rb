class RenameFailedtransactionsToFailedTransactions < ActiveRecord::Migration[5.0]
  def change
    rename_table :failedtransactions, :failed_transactions
  end
end
