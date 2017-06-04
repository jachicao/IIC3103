class GetPurchaseOrderJob < ApplicationJob
  queue_as :default

  def obtener_orden_de_compra(id)
    req_params = {
        :id => id,
        :_id => id,
      }
    return HTTParty.get(
      ENV['CENTRAL_SERVER_URL'] + '/oc/obtener/' + id, 
      :query => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json' }
      )
  end

  def perform(id)
    key = 'obtener_orden_de_compra:' + id
    cache_response = $redis.get(key)
    if cache_response != nil
      return {
          :body => JSON.parse(cache_response, symbolize_names: true),
          :code => 200,
      }
    end
    response = obtener_orden_de_compra(id)
    body = JSON.parse(response.body, symbolize_names: true)

    $redis.set(key, body.to_json)
    $redis.expire(key, ENV['CACHE_EXPIRE_TIME'].to_i.seconds.to_i)

    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end
end
