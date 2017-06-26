class CreatePromotions < ActiveRecord::Migration[5.0]
  def change
    create_table :promotions do |t|
      t.references :product, foreign_key: true
      t.integer :price
      t.datetime :starts_at
      t.datetime :expires_at
      t.string :code
      t.boolean :publish

      t.timestamps
    end
  end
end
