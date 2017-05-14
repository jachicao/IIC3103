class CreateRecipes < ActiveRecord::Migration[5.1]
  def change
    create_table :recipes do |t|
      t.references :product, foreign_key: true

      t.timestamps
    end
  end
end
