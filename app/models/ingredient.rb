class Ingredient < ApplicationRecord
  belongs_to :product
  belongs_to :item, class_name: 'Product', foreign_key: :item_id
end