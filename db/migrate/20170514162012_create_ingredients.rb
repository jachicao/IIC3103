class CreateIngredients < ActiveRecord::Migration[5.0]
  def change
    create_table :ingredients do |t|
      t.references :product, foreign_key: true
      t.bigint :item_id
      t.integer :quantity

      t.timestamps
    end
  end
end
