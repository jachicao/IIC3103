class DropTransactions < ActiveRecord::Migration[5.0]
  def change
    drop_table :transactions
  end
end
