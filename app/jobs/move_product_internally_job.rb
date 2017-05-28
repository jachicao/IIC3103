class MoveProductInternallyJob < ApplicationJob
  queue_as :default

  def mover_stock(productoId, almacenId)
    req_params = { 
        :productoId => productoId,
        :almacenId => almacenId,
      }
    auth_params = {
        :productoId => productoId,
        :almacenId => almacenId,
      }
    return HTTParty.post(
      ENV['CENTRAL_SERVER_URL'] + '/bodega/moveStock', 
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header('POST', auth_params) }
      )
  end

  def perform(product_id, to_store_house_id, from_store_house_id)
    $redis.del('get_almacenes')
    $redis.del('get_skus_with_stock:' + to_store_house_id)
    $redis.del('get_skus_with_stock:' + from_store_house_id)
    response = mover_stock(product_id, to_store_house_id)
    puts 'Moviendo'
    puts response.code
    puts response.body
    body = JSON.parse(response.body, symbolize_names: true)
    case response.code
      when 429
        #MoveProductInternallyJob.set(wait: 60.seconds).perform_later(product_id, to_store_house_id, from_store_house_id)
        return nil
    end
    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end
end
