class DispatchProductJob < ApplicationJob
  queue_as :default

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
    return HTTParty.delete(
      ENV['CENTRAL_SERVER_URL'] + '/bodega/stock', 
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header('DELETE', auth_params) }
      );
  end

  def perform(productoId, direccion, precio, oc)
    response = despachar_stock(productoId, direccion, precio, oc)
    #puts response
    body = JSON.parse(response.body, symbolize_names: true)
    case response.code
      when 429
        #DispatchProductJob.set(wait: 90.seconds).perform_later(productoId, direccion, precio, oc)
        return nil
    end
    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end
end
