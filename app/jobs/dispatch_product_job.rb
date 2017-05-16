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
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("DELETE", auth_params) }
      );
  end

  def perform(productoId, direccion, precio, oc)
  	response = despachar_stock(productoId, direccion, precio, oc)
    case response.code
      when 200
        puts "All good!"
      when 404
        puts "O noes not found!"
      when 500...600
        puts "ZOMG ERROR #{response.code}"
    end
  end
end
