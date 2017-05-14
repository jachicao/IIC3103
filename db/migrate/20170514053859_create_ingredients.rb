class CreateIngredients < ActiveRecord::Migration[5.1]
  def change
    create_table :ingredients do |t|
      t.references :product, foreign_key: true
      t.references :recipe, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
