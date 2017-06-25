class CreateBillItems < ActiveRecord::Migration[5.0]
  def change
    create_table :bill_items do |t|
      t.references :invoice, foreign_key: true
      t.references :product, foreign_key: true
      t.integer :quantity
      t.integer :unit_price

      t.timestamps
    end
  end
end
