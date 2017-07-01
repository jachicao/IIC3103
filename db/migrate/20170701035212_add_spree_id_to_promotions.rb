class AddSpreeIdToPromotions < ActiveRecord::Migration[5.0]
  def change
    add_column :promotions, :spree_id, :integer
  end
end
