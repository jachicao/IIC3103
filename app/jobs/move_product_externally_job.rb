class MoveProductExternallyJob < ApplicationJob
  queue_as :default

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
    return HTTParty.post(
      ENV['CENTRAL_SERVER_URL'] + '/bodega/moveStockBodega', 
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header('POST', auth_params) }
      )
  end

  def perform(productoId, almacenId, oc, precio)
    response = mover_stock_bodega(productoId, almacenId, oc, precio)
    #puts response
    body = JSON.parse(response.body, symbolize_names: true)
    case response.code
      when 429
        #MoveProductExternallyJob.set(wait: 90.seconds).perform_later(productoId, almacenId, oc, precio)
        return nil
    end
    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end
end
