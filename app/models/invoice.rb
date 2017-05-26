class Invoice < ApplicationRecord
  belongs_to :purchase_order
end
