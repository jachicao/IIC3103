class CreateAzurePurchaseOrderOverTime < ActiveRecord::Migration[5.0]
  def change
    create_table :azure_purchase_order_over_times do |t|
      t.references :azure_date, foreign_key: true
      t.references :azure_purchase_order, foreign_key: true
      t.string :status
      t.integer :quantity_dispatched
    end
  end
end
