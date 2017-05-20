class GetProductsWithStockJob < ApplicationJob
  queue_as :default

  def get_skus_with_stock(almacenId)
    req_params = {
        :almacenId => almacenId,
      }
    auth_params = {
        :almacenId => almacenId,
      }
    return HTTParty.get(
      ENV['CENTRAL_SERVER_URL'] + '/bodega/skusWithStock', 
      :query => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header('GET', auth_params) }
      )
  end

  def perform(almacenId)

    key = 'get_skus_with_stock:' + almacenId
    cache_response = $redis.get(key)
    if cache_response != nil
      return {
          :body => JSON.parse(cache_response, symbolize_names: true)
      }
    end

    response = get_skus_with_stock(almacenId)
    puts response.body
    puts response.code
    body = JSON.parse(response.body, symbolize_names: true)
    case response.code
      when 429
        #GetProductsWithStockJob.set(wait: ENV['SERVER_RATE_LIMIT_TIME'].to_i.seconds).perform_later(almacenId)
        return nil
    end

    $redis.set(key, body.to_json)
    $redis.expire(key, ENV['ALMACENES_CACHE_EXPIRE_TIME'].to_i.seconds.to_i)
    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end
end
