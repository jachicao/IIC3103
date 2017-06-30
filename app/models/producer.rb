class Producer < ApplicationRecord
  has_many :product_in_sales
  has_many :products, through: :product_in_sales

  def self.get_me
    return Producer.find_by(group_number: ENV['GROUP_NUMBER'].to_i)
  end

  def is_me
    return self.group_number == ENV['GROUP_NUMBER'].to_i
  end

  def has_wrong_products_api
    invalid_groups = [6, 8]
    return invalid_groups.include?(self.group_number)
  end

  def has_wrong_purchase_orders_api
    invalid_groups = [6, 8] #TODO: remove this
    return invalid_groups.include?(self.group_number)
  end

  def get_access_token
    return ENV['GROUP_ID']
  end

  def get_api_route
    case self.group_number
      when 1
        return '/api'
      when 7
        return '/api'
      else
        return ''
    end
  end

  def get_base_url
    return (ENV['GROUPS_SERVER_URL'] % [self.group_number])
  end

  def get_spree_url
    return (ENV['GROUPS_SERVER_URL'] % [self.group_number]) + '/spree'
  end

  def get_prices_route
    case self.group_number
      when 6
        return self.get_api_route + '/products'
    end
    return '/api/publico/precios'
  end

  def get_api_url
    return self.get_base_url + self.get_api_route
  end

  def get_headers_without_token
    return {
        content_type: 'application/json',
        accept: 'application/json',
    }
  end

  def get_headers
    return {
        content_type: 'application/json',
        accept: 'application/json',
        authorization: self.get_access_token,
        'X-ACCESS-TOKEN' => self.get_access_token,
    }
  end

  def use_rest_client
    case self.group_number
      when 2
        return true
      when 6
        return true
      else
        return false
    end
  end

end