class AddSpreePromotionIdToPromotions < ActiveRecord::Migration[5.0]
  def change
    add_column :promotions, :spree_promotion_id, :integer
  end
end
