class FixAccountName < ActiveRecord::Migration[5.0]
  def change
    rename_column :producers, :account, :bank_account
  end
end
