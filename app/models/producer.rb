class Producer < ApplicationRecord
  has_many :product_in_sales

  def self.get_me
    return Producer.all.find_by(group_number: ENV['GROUP_NUMBER'].to_i)
  end

  def is_me
    return self.group_number == ENV['GROUP_NUMBER'].to_i
  end
end