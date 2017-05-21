class Producer < ApplicationRecord
  has_many :product_in_sales
  before_create :set_me

  def set_me
    self.me = group_number == ENV['GROUP_NUMBER'].to_i
  end
end