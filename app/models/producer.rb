class Producer < ApplicationRecord
  has_many :product_in_sales

  def self.get_me
    return Producer.find_by(group_number: ENV['GROUP_NUMBER'].to_i)
  end

  def is_me
    return self.group_number == ENV['GROUP_NUMBER'].to_i
  end

  def has_wrong_api
    invalid_groups = [6, 8] #TODO: remove this
    return invalid_groups.include?(self.group_number)
  end
end