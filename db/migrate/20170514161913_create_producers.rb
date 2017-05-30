class CreateProducers < ActiveRecord::Migration[5.0]
  def change
    create_table :producers do |t|
      t.string :producer_id
      t.integer :group_number
      t.string :account

      t.timestamps
    end
    add_index :producers, :producer_id
  end
end
