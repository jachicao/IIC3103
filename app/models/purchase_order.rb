class PurchaseOrder < ApplicationRecord
  validates :channel, presence: true
  validates :supplier, presence: true
  validates :client, presence: true
  validates :Sku, presence: true
  validates :quantity, presence: true
  validates :unitPrice, presence: true


end
