class CreateAzureBankTransaction < ActiveRecord::Migration[5.0]
  def change
    create_table :azure_bank_transactions do |t|
      t.string :_id
      t.string :from
      t.string :to
      t.integer :amount
    end
    add_index :azure_bank_transactions, :_id
  end
end
