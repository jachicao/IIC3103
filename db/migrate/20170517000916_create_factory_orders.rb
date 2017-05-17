class CreateFactoryOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :factory_orders do |t|
      t.string :fo_id
      t.string :sku
      t.integer :group
      t.boolean :dispatched
      t.datetime :available
      t.integer :quantity

      t.timestamps
    end
    add_index :factory_orders, :fo_id
  end
end
