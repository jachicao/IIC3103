class StoreHouse < ApplicationRecord
  has_many :stocks, dependent: :destroy

  def type
    if self.pulmon
      return 'Pulmón'
    elsif self.despacho
      return 'Despacho'
    elsif self.recepcion
      return 'Recepción'
    end
    if self.total_space >= 20000
      return 'General'
    else
      return 'Pre-General'
    end
  end

  def self.get_despacho
    self.all.each do |store_house|
      if store_house.despacho
        return store_house
      end
    end
    return nil
  end


  def self.get_recepcion
    self.all.each do |store_house|
      if store_house.recepcion
        return store_house
      end
    end
    return nil
  end


  def self.get_stock_total_not_despacho(sku)
    total_not_despacho = 0
    StoreHouse.all.each do |store_house|
      if store_house.despacho
      else
        store_house.stocks.each do |s|
          if s.product.sku == sku
            total_not_despacho += s.quantity
          end
        end
      end
    end
    return total_not_despacho
  end

  def self.can_move_stock(from_store_house_id, to_store_house_id, sku, quantity)
    quantity_moved = 0
    from_store_house = StoreHouse.find_by(_id: from_store_house_id)
    to_store_house = StoreHouse.find_by(_id: to_store_house_id)
    from_store_house.stocks.each do |s|
      if s.product.sku == sku
        available_space = to_store_house.available_space
        if available_space > 0
          quantity_moved += [available_space, s.quantity].min
        end
      end
    end
    return quantity_moved >= quantity
  end

  def self.move_stock(from_store_house_id, to_store_house_id, sku, quantity)
    MoveProductsInternallyWorker.perform_async(from_store_house_id, to_store_house_id, sku, quantity)
  end

  def self.move_stocks(from_store_houses, to_store_houses, sku, quantity)
    quantity_left = quantity
    to_store_houses.each do |to_store_house|
      to_total_space = to_store_house.total_space
      to_used_space = to_store_house.used_space
      if to_total_space - to_used_space > 0
        from_store_houses.each do |from_store_house|
          from_store_house.stocks.each do |s|
            if s.product.sku == sku and s.quantity > 0
              limit = [to_total_space - to_used_space, s.quantity, quantity_left].min
              self.move_stock(from_store_house._id, to_store_house._id, sku, limit)
              quantity_left -= limit
              to_used_space += limit
            end
          end
        end
      end
    end
    return quantity_left <= 0
  end

  def available_space
    return self.total_space - self.used_space
  end

  def used_space
    total = 0
    self.stocks.each do |s|
      total += s.quantity
    end
    return total
  end

  def self.can_send_request
    if $store_houses_request == nil
      $store_houses_request = []
    end
    current_time = DateTime.current
    size = $store_houses_request.size
    if size < ENV['SERVER_RATE_LIMIT'].to_i
      $store_houses_request.push(current_time)
      return true
    else
      first = $store_houses_request[0]
      if (first + ENV['SERVER_RATE_LIMIT_TIME'].to_i.seconds) < current_time
        for i in 0..size - 2
          $store_houses_request[i] = $store_houses_request[i + 1]
        end
        $store_houses_request[size] = current_time
        return true
      else
        return false
      end
    end
  end

  def self.is_dispatching_products
    PurchaseOrder.all.each do |purchase_order|
      if purchase_order.is_dispatching
        return true
      end
    end
    return false
  end

  def self.is_producing_products
    PendingProduct.all.each do |pending_product|
      if pending_product.has_stock
        return true
      end
    end
    return false
  end

  def self.despacho_being_used
    return self.is_dispatching_products || self.is_producing_products
  end
end