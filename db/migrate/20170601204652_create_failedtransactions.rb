class CreateFailedtransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :failedtransactions do |t|
      t.string :_id
      t.string :origin
      t.string :destination
      t.integer :amount

      t.timestamps
    end
  end
end
