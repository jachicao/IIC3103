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
    if store_houses == nil
      return nil
    end
    result = []
    store_houses.each do |s|
      store_house = s
      store_house[:inventario] = []
      if store_house[:usedSpace] > 0
        stock = get_stock(store_house[:_id])
        if stock == nil
          return nil
        end
        stock.each do |b|
          store_house[:inventario].push({ sku: b[:_id], total: b[:total] })
        end
      end
      result.push(store_house)
    end
    return result
  end

  def self.get_store_house(id)
    return all.find(_id: id).first
  end

  def self.get_stock(id)
    response = GetProductsWithStockJob.perform_now(id)
    if response == nil
      return nil
    end
    result = []
    response[:body].each do |b|
      result.push({ sku: b[:_id], total: b[:total] })
    end
    return result
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

  def self.clean_store_house(from_store_houses, to_store_houses)
    used_space = 0
    from_store_houses.each do |store_house|
      used_space += store_house[:usedSpace]
    end
    if used_space == 0
      return used_space
    end

    to_store_houses.sort! { |x, y| y[:availableSpace] <=> x[:availableSpace] }

    #mover stock desde un almacen a otro
    to_store_houses.each do |to_store_house|
      if to_store_house[:availableSpace] > 0
        from_store_houses.each do |from_store_house|
          if from_store_house[:usedSpace] > 0
            stock = get_stock(from_store_house[:_id])
            if stock == nil
              return used_space
            end
            stock.each do |p|
              if to_store_house[:availableSpace] > 0 and p[:total] > 0
                total_to_move = [to_store_house[:availableSpace], p[:total]].min
                MoveProductsBetweenStoreHousesJob.perform_later(to_store_house[:_id], from_store_house[:_id], p[:sku], total_to_move)
                p[:total] -= total_to_move
                to_store_house[:availableSpace] -= total_to_move
                to_store_house[:usedSpace] += total_to_move
                from_store_house[:availableSpace] += total_to_move
                from_store_house[:usedSpace] -= total_to_move
                used_space -= total_to_move
              end
            end
          end
        end
      end
    end
    return used_space
  end

  def self.clean_recepcion
    recepcion = get_recepciones

    if recepcion == nil
      return { :error => 'Servidor colapsado' }
    end

    general = get_otros

    if general == nil
      return { :error => 'Servidor colapsado' }
    end

    return clean_store_house(recepcion, general)
  end

  def self.clean_pulmon
    pulmon = get_pulmones

    if pulmon == nil
      return { :error => 'Servidor colapsado' }
    end

    general = get_otros

    if general == nil
      return { :error => 'Servidor colapsado' }
    end

    return clean_store_house(pulmon, general)
  end

  def self.move_stock(from_store_houses, to_store_houses, sku, quantity)
    quantity_left = quantity
    from_store_houses.each do |from_store_house|
      if from_store_house[:usedSpace] > 0
        stock = get_stock(from_store_house[:_id])
        if stock == nil
          return quantity_left
        end
        stock.each do |p|
          if p[:sku] == sku
            to_store_houses.each do |to_store_house|
              if to_store_house[:availableSpace] > 0
                if quantity_left > 0 and p[:total] > 0
                  total_to_move = [to_store_house[:availableSpace], p[:total], quantity_left].min
                  MoveProductsBetweenStoreHousesJob.perform_later(to_store_house[:_id], from_store_house[:_id], sku, total_to_move)
                  p[:total] -= total_to_move
                  to_store_house[:availableSpace] -= total_to_move
                  to_store_house[:usedSpace] += total_to_move
                  from_store_house[:availableSpace] += total_to_move
                  from_store_house[:usedSpace] -= total_to_move
                  quantity_left -= total_to_move
                end
              end
            end
          end
        end
      end
    end
    return quantity_left
  end

  def self.move_to_despacho(sku, quantity) #cantidad de un sku que hay que llevar a despacho
    quantity_left = quantity

    despacho = get_despachos
    if despacho == nil
      return nil
    end

    #mover stock desde general
    general = get_otros
    if general == nil
      return nil
    end

    quantity_left = move_stock(general, despacho, sku, quantity_left)

    if quantity_left == 0
      return { :message => 'Movido a despacho' };
    end

    #mover stock desde recepcion
    recepcion = get_recepciones
    if recepcion == nil
      return nil
    end

    quantity_left = move_stock(recepcion, despacho, sku, quantity_left)

    if quantity_left == 0
      return { :message => 'Movido a despacho' };
    end


    #mover stock desde pulmon
    pulmon = get_pulmones
    if pulmon == nil
      return nil
    end
    quantity_left = move_stock(pulmon, despacho, sku, quantity_left)

    if quantity_left == 0
      return { :message => 'Movido a despacho' };
    else
      return { :error => 'Falta stock por mover: ' + quantity_left }
    end
  end
end