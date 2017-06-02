class MoveProductInternallyJob < ApplicationJob
  queue_as :default

  def mover_stock(producto_id, almacen_id)
    req_params = { 
        :productoId => producto_id,
        :almacenId => almacen_id,
      }
    auth_params = {
        :productoId => producto_id,
        :almacenId => almacen_id,
      }
    return HTTParty.post(
      ENV['CENTRAL_SERVER_URL'] + '/bodega/moveStock', 
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header('POST', auth_params) }
      )
  end

  def perform(product_id, from_store_house_id, to_store_house_id)
    $redis.del('get_skus_with_stock:' + to_store_house_id)
    $redis.del('get_skus_with_stock:' + from_store_house_id)
    response = mover_stock(product_id, to_store_house_id)
    puts 'Moviendo internamente: '
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
