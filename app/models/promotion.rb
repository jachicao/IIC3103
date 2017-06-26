class Promotion < ApplicationRecord
  belongs_to :product
  belongs_to :spree_promotion, class_name: 'Spree::Promotion', dependent: :destroy
end
