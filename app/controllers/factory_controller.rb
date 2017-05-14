class FactoryController < ApplicationController

    def producir_stock_sin_pagar
      req_params = {
          :sku => params[:sku],
          :cantidad => params[:cantidad],
        }
      res = HTTParty.put(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/fabrica/fabricarSinPago', 
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("PUT", req_params) }
        )
      return res
    end

    def producir_stock
      req_params = {
          :trxId => params[:trxId],
          :sku => params[:sku],
          :cantidad => params[:cantidad],
        }
      res = HTTParty.put(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/fabrica/fabricar', 
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("PUT", req_params) }
        )
      return res
    end

    def get_cuenta
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
