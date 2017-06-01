class MoveProductExternallyJob < ApplicationJob
  queue_as :default

  def mover_stock_bodega(producto_id, almacen_id, oc, precio)
    req_params = { 
        :productoId => producto_id,
        :almacenId => almacen_id,
        :oc => oc,
        :precio => precio,
      }
    auth_params = {
        :productoId => producto_id,
        :almacenId => almacen_id,
      }
    return HTTParty.post(
      ENV['CENTRAL_SERVER_URL'] + '/bodega/moveStockBodega', 
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header('POST', auth_params) }
      )
  end

  def perform(producto_id, from_store_house_id, to_store_house_id, oc, precio)
    $redis.del('get_almacenes')
    $redis.del('get_skus_with_stock:' + from_store_house_id)
    response = mover_stock_bodega(producto_id, to_store_house_id, oc, precio)
    puts 'Moviendo externamente'
    puts response.code
    #puts response.body
    body = JSON.parse(response.body, symbolize_names: true)
    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end
end
