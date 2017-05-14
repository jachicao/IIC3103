class StoreHouseController < ApplicationController

    def despachar_stock(productoId, oc, direccion, precio)
      req_params = { 
          :productoId => productoId,
          :oc => oc,
          :direccion => direccion,
          :precio => precio,
        }
      res = HTTParty.delete(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/stock', 
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("DELETE", req_params) }
        )
      return res
    end

    def mover_stock(productoId, almacenId)
      req_params = { 
          :productoId => productoId,
          :almacenId => almacenId,
        }
      res = HTTParty.post(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/moveStock', 
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("POST", req_params) }
        )
      return res
    end

    def get_almacenes()
      req_params = {
        }
      res = HTTParty.get(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/almacenes', 
        :query => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("GET", req_params) }
        )
      return res
    end

    def get_stock(almacenId, sku)
      req_params = {
          :almacenId => almacenId,
          :sku => sku,
        }
      res = HTTParty.get(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/stock', 
        :query => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("GET", req_params) }
        )
      return res
    end

    def get_skus_with_stock(almacenId)
      req_params = {
          :almacenId => almacenId,
        }
      res = HTTParty.get(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/skusWithStock', 
        :query => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("GET", req_params) }
        )
      return res
    end
end
