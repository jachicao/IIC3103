class StoreHouseController < ApplicationController

    def before
      key = "Almacenes";
      cache_result = $redis.get(key);
      if cache_result.nil?
        result = []
        almacenes = get_almacenes()
        almacenes.each do |a|
          almacen = a
          almacenId = a["_id"]
          skusWithStock = get_skus_with_stock(almacenId)
          #puts skusWithStock
          almacen["inventario"] = []
          inventario = almacen["inventario"]
          skusWithStock.each do |b|
            sku = b["_id"]
            total = b["total"]
            inventario.push({ sku: sku, total: total });
            #skuStock = get_stock(almacenId, sku)
            #puts skuStock
          end
          result.push(almacen);
        end
        cache_result = result.to_json
        $redis.set(key, cache_result);
        $redis.expire(key, 90.seconds.to_i)
      end
      DispatchProductJob.perform_later(nil)
      return JSON.load(cache_result)
    end

    def index
      render json: before()
    end

    private
      # producer has many almacenes
      # almacen has many products

      def get_almacenes()
        req_params = {
          }
        auth_params = {
          }
        res = HTTParty.get(
          ENV['CENTRAL_SERVER_URL'] + '/bodega/almacenes', 
          :query => req_params,
          :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("GET", auth_params) }
          )
        return JSON.parse(res.body)
      end

      def get_skus_with_stock(almacenId)
        req_params = {
            :almacenId => almacenId,
          }
        auth_params = {
            :almacenId => almacenId,
          }
        res = HTTParty.get(
          ENV['CENTRAL_SERVER_URL'] + '/bodega/skusWithStock', 
          :query => req_params,
          :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("GET", auth_params) }
          )
        return JSON.parse(res.body)
      end

      def get_stock(almacenId, sku)
        req_params = {
            :almacenId => almacenId,
            :sku => sku,
            :limit => 200,
          }
        auth_params = {
            :almacenId => almacenId,
            :sku => sku,
          }
        res = HTTParty.get(
          ENV['CENTRAL_SERVER_URL'] + '/bodega/stock', 
          :query => req_params,
          :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("GET", auth_params) }
          )
        return JSON.parse(res.body)
      end

      def mover_stock(productoId, almacenId)
        req_params = { 
            :productoId => productoId,
            :almacenId => almacenId,
          }
        auth_params = {
            :productoId => productoId,
            :almacenId => almacenId,
          }
        res = HTTParty.post(
          ENV['CENTRAL_SERVER_URL'] + '/bodega/moveStock', 
          :body => req_params,
          :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("POST", auth_params) }
          )
        return JSON.parse(res.body)
      end

      def mover_stock_bodega(productoId, almacenId, oc, precio)
        req_params = { 
            :productoId => productoId,
            :almacenId => almacenId,
            :oc => oc,
            :precio => precio,
          }
        auth_params = {
            :productoId => productoId,
            :almacenId => almacenId,
          }
        res = HTTParty.post(
          ENV['CENTRAL_SERVER_URL'] + '/bodega/moveStockBodega', 
          :body => req_params,
          :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("POST", auth_params) }
          )
        return JSON.parse(res.body)
      end

      def despachar_stock(productoId, direccion, precio, oc)
        req_params = {
            :productoId => productoId,
            :direccion => direccion,
            :precio => precio,
            :oc => oc,
          }
        auth_params = {
            :productoId => productoId,
            :direccion => direccion,
            :precio => precio,
            :oc => oc,
          }
        res = HTTParty.delete(
          ENV['CENTRAL_SERVER_URL'] + '/bodega/stock', 
          :body => req_params,
          :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("DELETE", auth_params) }
          )
        return JSON.parse(res.body)
      end
end
