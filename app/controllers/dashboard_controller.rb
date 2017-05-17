class DashboardController < ApplicationController

    
    def getWarehouseWithStock
      result = []
      almacenes = GetStoreHousesJob.perform_now()
      if almacenes == nil then
        return { :error => "No cache" }
      end
      almacenes.each do |a|
        almacen = a
        tipo = nil;

        if almacen["despacho"] == true
          tipo = "Despacho"
        elsif almacen["recepcion"] == true
          tipo = "Recepción"
        elsif almacen["pulmon"] == true
          tipo = "Pulmón"
        else
          tipo = "General"
        end

        disponible = almacen["totalSpace"] - almacen["usedSpace"]
        result.push({tipo: tipo, capacidad: almacen["totalSpace"], disponible: disponible, utilizado: almacen["usedSpace"]})
      end

      return result
    end

    def getProductsWithStock
      #Get every product owned by group and save the list on myProducts
      productsInSale = ProductInSale.all
      myProducts = []

      productsInSale.each do |p|
        if p.producer.group_number == 1 
          sku = p.product.sku
          nombre = p.product.name
          stock = 0
          myProducts.push({sku: sku, nombre: nombre, stock: stock})
        end
      end

      #Update myProducts with the stock of every product owned by group
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
        #puts skusWithStock
        skusWithStock.each do |b|
          sku = b["_id"]
          total = b["total"]
          myProducts.each do |product|
            if sku == product[:sku]
              product[:stock] = product[:stock] + total
              break
            end
          end
        end
      end 

      return myProducts

    end

    def getSentFactoryOrders
      factoryOrders = FactoryOrder.all
      sentFactoryOrders = []

      factoryOrders.each do |f|
        sku = f.sku
        cantidad = f.quantity
        fechaDisponible = f.available
        sentFactoryOrders.push({sku: sku, cantidad: cantidad, fechaDisponible: fechaDisponible})
      end

      return sentFactoryOrders
    end

    def index
      @almacenes = getWarehouseWithStock
      @productos = getProductsWithStock
      @factoryOrders = getSentFactoryOrders
    end
    
end
