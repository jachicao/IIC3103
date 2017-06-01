class DispatchProductJob < ApplicationJob
  queue_as :default

  def despachar_stock(producto_id, direccion, precio, oc)
    req_params = {
        :productoId => producto_id,
        :direccion => direccion,
        :precio => precio,
        :oc => oc,
      }
    auth_params = {
        :productoId => producto_id,
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

  def perform(producto_id, from_store_house_id, direccion, precio, oc)
    $redis.del('get_almacenes')
    $redis.del('get_skus_with_stock:' + from_store_house_id)
    response = despachar_stock(producto_id, direccion, precio, oc)
    puts 'Moviendo'
    puts response.code
    puts response.body
    #puts response
    body = JSON.parse(response.body, symbolize_names: true)
    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end
end
