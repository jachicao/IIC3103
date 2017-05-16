class StoreHouse
  def getStock
    result = []
    almacenes = GetStoreHousesJob.perform_now()
    if almacenes == nil then
      return { :error => "No cache" }
    end
    almacenes.each do |a|
      almacen = a
      almacenId = a["_id"]
      skusWithStock = GetProductsWithStockJob.perform_now(almacenId)
      if skusWithStock == nil then
        return { :error => "No cache" }
      end

      almacen["inventario"] = []
      inventario = almacen["inventario"]
      skusWithStock.each do |b|
        sku = b["_id"]
        total = b["total"]
        inventario.push({ sku: sku, total: total });
      end
      result.push(almacen);
    end
    #puts MakeProductsWithoutPaymentJob.perform_now("49", 200) #<= Sync
    #puts MakeProductsWithoutPaymentJob.perform_late("49", 200) #<= Async
    return result
  end

  def clearReception
    almacenes = getStock()
    if almacenes == nil then
      return { :error => "No cache" }
    end

    # Aquí se obtiene el id del almacen al que se moverán los productos de recepcion (el de mayor capacidad)
    capacidad = 0
    almacenId = 0
    recepcion = nil
    almacenes.each do |a|
      if !a["recepcion"] && !a["despacho"] && !a["pulmon"]  #se revisa que el almacen no sea pulmon, recepcion o despacho
        if capacidad < a["totalSpace"]  && a["totalSpace"] != a["usedSpace"] # se busca el de mayor capacidad disponible
          almacenId = a["_id"]
          capacidad = a["totalSpace"]
        end
      elsif a["recepcion"]
        recepcion = a
      end
    end

    if recepcion
      if recepcion["inventario"]
        inventario = recepcion["inventario"]  # se obtiene el inventario
        total_a_mover = 0
        inventario.each do |i|
          total_a_mover += i[:total]
          count = i[:total] / 200
          if i[:total] % 200 > 0
            count +=  1
          end
          while count > 0 and total_a_mover < capacidad
            productos = GetProductStockJob.perform_now(recepcion["_id"], i[:sku]) # se buscan todos los productos de un sku
            productos.each do |p|
              MoveProductInternallyJob.perform_now(p["_id"], almacenId) #cada producto se mueve al almacen de mayor capacidad que no es despacho ni recepcion
            end
            count -= 1
          end
        end
      end
    end
    return { message: 'Recepcion liberada'};
  end




  def movetoDespatch(sku, quantity) #cantidad de un sku que hay que llevar a despacho
    almacenes = getStock()
    if almacenes == nil then
      return { :error => "No cache" }
    end
    almacenamiento = []
    stock = 0
    despachoId = 0
    almacenes.each do |a|
      if !a["despacho"] && !a["pulmon"]
        id = a["_id"]
        inventario = a["inventario"]
        inv = 0
        inventario.each do |i|
          if i[:sku] == sku
            inv = i[:total]
          end
        end
        if inv > 0
          stock += inv
          almacenamiento.push({ _id: id, inventario: inv})
        end
      elsif a["despacho"]
        despachoId = a["_id"]
      end
    end

    if stock >= quantity
      while quantity > 0
        almacenamiento.each do |m|
          cantidad =  m[:inventario]
          while cantidad > 0
            productos = GetProductStockJob.perform_now(m[:_id], sku) # se buscan todos los productos de un sku
            productos.each do |p|
              MoveProductInternallyJob.perform_now(p["_id"], despachoId)
              cantidad -= 1
              quantity -= 1
            end
          end
        end
      end
      return { message: 'Movido a despacho', status: 'ok'};
    else
      aux = quantity- stock
      # while stock > 0
      #   almacenamiento.each do |m|
      #     cantidad =  m[:inventario]
      #     while cantidad > 0
      #       productos = GetProductStockJob.perform_later(m[:_id], sku) # se buscan todos los productos de un sku
      #       productos.each do |p|
      #         MoveProductInternallyJob.perform_later(p["_id"], despachoId)
      #         cantidad -= 1
      #         stock -= 1
      #       end
      #     end
      #   end
      # end
      return { message: 'Falta stock', status: 'not ok', missing: aux};
    end
  end


  def movebetweenStoreHouses(almacen1, almacen2, sku, cantidad)
    error = 0
    while cantidad > 0
      productos = GetProductStockJob.perform_now(almacen1, sku) # se buscan todos los productos de un sku
      if productos.empty?
        error= 1
      end
      productos.each do |p|
        if cantidad > 0
            MoveProductInternallyJob.perform_now(p["_id"], almacen2)
            cantidad -= 1
          end
      end
      if error == 1
        break
      end
    end
    if error == 1
      return  {message: 'error'};
    else
      return {message: 'ok'};
    end
  end


  def movements
    clearReception()
    almacenes = getStock()
    if almacenes == nil then
      return { :error => "No cache" }
    end

    almacenes.each do |a|
      if a["recepcion"]
        recepcionId = a["_id"]
        capacidad = a["totalSpace"] - a["usedSpace"]
      end
    end

    almacenes.each do |a|
      if a["pulmon"]
        if a["usedSpace"] > 0
          inventario = a["inventario"]
          inventario.each do |i|
            if capacidad >= i["total"]
              response = movebetweenStoreHouses(a["_id"], recepcionId, i["sku"], i["total"])
              if response["message"] == "ok"
                capacidad -= i["total"]
              end
            elsif capacidad < i["total"]
              response = movebetweenStoreHouses(a["_id"], recepcionId, i["sku"], capacidad)
              if response["message"] == "ok"
                capacidad = 0
              end
            end
          end
        end
      end
    end
  end


end