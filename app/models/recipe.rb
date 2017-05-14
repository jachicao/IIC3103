class Recipe < ApplicationRecord
  belongs_to :product
  has_many :ingredients
  accepts_nested_attributes_for :ingredients
end