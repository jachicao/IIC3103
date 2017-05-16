class StoreHouseController < ApplicationController

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
        #puts skusWithStock
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

    def index
      render json: getStock();
    end
    
end
