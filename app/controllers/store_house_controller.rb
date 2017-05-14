class StoreHouseController < ApplicationController

    def get_almacenes
      req_params = {
        }
      res = HTTParty.get(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/almacenes', 
        :query => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("GET", req_params) }
        )
      return res
    end

    def get_skus_with_stock
      req_params = {
          :almacenId => params[:almacenId],
        }
      res = HTTParty.get(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/skusWithStock', 
        :query => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("GET", req_params) }
        )
      return res
    end

    def get_stock
      req_params = {
          :almacenId => params[:almacenId],
          :sku => params[:sku],
        }
      res = HTTParty.get(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/stock', 
        :query => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("GET", req_params) }
        )
      return res
    end

    def mover_stock
      req_params = { 
          :productoId => params[:productoId],
          :almacenId => params[:almacenId],
        }
      res = HTTParty.post(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/moveStock', 
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("POST", req_params) }
        )
      return res
    end

    def despachar_stock
      req_params = { 
          :productoId => params[:productoId],
          :oc => params[:oc],
          :direccion => params[:direccion],
          :precio => params[:precio],
        }
      res = HTTParty.delete(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/stock', 
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("DELETE", req_params) }
        )
      return res
    end
end
