class CreateAzurePurchaseOrder < ActiveRecord::Migration[5.0]
  def change
    create_table :azure_purchase_orders do |t|
      t.references :azure_product, foreign_key: true
      t.string :_id
      t.string :payment_method
      t.string :store_reception_id
      t.integer :quantity
      t.string :client
      t.string :supplier
      t.integer :unit_price
      t.datetime :delivery_date
      t.string :channel
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :azure_purchase_orders, :_id
  end
end
