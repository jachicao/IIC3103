Spree::Order.class_eval do
  has_one :invoice, foreign_key: :spree_order_id
end