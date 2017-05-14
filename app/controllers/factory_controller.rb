class FactoryController < ApplicationController

    def producir_stock_sin_pagar(sku, cantidad)
      req_params = {
          :sku => sku,
          :cantidad => cantidad,
        }
      res = HTTParty.put(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/fabrica/fabricarSinPago', 
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("PUT", req_params) }
        )
      return res
    end

    def producir_stock(trxId, sku, cantidad)
      req_params = {
          :trxId => trxId,
          :sku => sku,
          :cantidad => cantidad,
        }
      res = HTTParty.put(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/fabrica/fabricar', 
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("PUT", req_params) }
        )
      return res
    end

    def get_cuenta()
      req_params = {
        }
      res = HTTParty.get(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/fabrica/getCuenta', 
        :query => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("GET", req_params) }
        )
      return res
    end
end
