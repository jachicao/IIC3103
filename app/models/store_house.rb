class StoreHouse

  def self.all
    result = []
    response = GetStoreHousesJob.perform_now
    if response == nil
      return nil
    end
    store_houses = response[:body]
    store_houses.each do |s|
      store_house = s
      store_house[:availableSpace] = store_house[:totalSpace] - store_house[:usedSpace]
      if store_house[:pulmon]
        store_house[:type] = 'Pulmón'
      elsif store_house[:despacho]
        store_house[:type] = 'Despacho'
      elsif store_house[:recepcion]
        store_house[:type] = 'Recepción'
      else
        store_house[:type] = 'General'
      end
      result.push(store_house)
    end
    return result
  end

  def self.all_stock
    store_houses = all
    if store_houses.nil?
      return nil
    end
    result = []
    store_houses.each do |s|
      store_house = s
      store_house[:inventario] = []
      inventario = store_house[:inventario]
      if store_house[:usedSpace] > 0
        stock = get_stock(store_house[:_id])
        if stock.nil?
          return nil
        end
        stock.each do |b|
          inventario.push({ sku: b[:sku], total: b[:total] })
        end
      end
      result.push(store_house)
    end
    return result
  end

  def self.get_store_house(id)
    result = all
    if result.nil?
      return nil
    end
    result.each do |store_house|
      if store_house[:_id] == id
        return store_house
      end
    end
    return nil
  end

  def self.get_stock(id)
    response = GetProductsWithStockJob.perform_now(id)
    if response.nil?
      return nil
    end
    result = []
    response[:body].each do |b|
      result.push({ sku: b[:_id], total: b[:total] })
    end
    return result
  end

  def self.get_used_space(id)
    stock = get_stock(id)
    if stock.nil?
      return nil
    end
    total = 0
    stock.each do |p|
      total += p[:total]
    end
    return total
  end

  def self.get_despachos
    result = []
    store_houses = all
    if store_houses == nil
      return nil
    end
    store_houses.each do |store_house|
      if store_house[:despacho]
        result.push(store_house)
      end
    end
    return result
  end

  def self.get_recepciones
    result = []
    store_houses = all
    if store_houses == nil
      return nil
    end
    store_houses.each do |store_house|
      if store_house[:recepcion]
        result.push(store_house)
      end
    end
    return result
  end

  def self.get_pulmones
    result = []
    store_houses = all
    if store_houses == nil
      return nil
    end
    store_houses.each do |store_house|
      if store_house[:pulmon]
        result.push(store_house)
      end
    end
    return result
  end

  def self.get_otros
    result = []
    store_houses = all
    if store_houses == nil
      return nil
    end
    store_houses.each do |store_house|
      if (!store_house[:despacho]) and (!store_house[:recepcion]) and (!store_house[:pulmon])
        result.push(store_house)
      end
    end
    return result
  end

  def self.get_stock_total_not_despacho(sku)
    store_houses = all
    if store_houses.nil?
      return nil
    end
    total_not_despacho = 0
    store_houses.each do |store_house|
      if store_house[:despacho]
      else
        stock = get_stock(store_house[:_id])
        if stock.nil?
          return nil
        end
        stock.each do |p|
          if p[:sku] == sku
            total_not_despacho += p[:total]
          end
        end
      end
    end
    return total_not_despacho
  end

  def self.can_move_stock(from_store_houses, to_store_houses, sku, quantity)
    quantity_moved = 0
    from_store_houses.each do |from_store_house|
      from_stock = get_stock(from_store_house[:_id])
      if from_stock.nil?
        return nil
      end
      from_stock.each do |p|
        if p[:sku] == sku
          to_store_houses.each do |to_store_house|
            to_total_space = to_store_house[:totalSpace]
            to_used_space = get_used_space(to_store_house[:_id])
            if to_used_space.nil?
              return nil
            end
            if to_total_space - to_used_space > 0
              quantity_moved += [to_total_space - to_used_space, p[:total]].min
            end
          end
        end
      end
    end
    return quantity_moved >= quantity
  end

  def self.move_stock(from_store_houses, to_store_houses, sku, quantity)
    MoveProductsInternallyWorker.perform_async(from_store_houses, to_store_houses, sku, quantity)
  end
end