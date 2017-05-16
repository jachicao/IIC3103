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
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("GET", auth_params) }
      )
  end

  def perform(almacenId)

    fast_key = "fast:get_skus_with_stock:" + almacenId
    fast_cache_response = $redis.get(fast_key)
    if fast_cache_response != nil
      return JSON.load(fast_cache_response)
    end

    key = "get_skus_with_stock:" + almacenId
    response = get_skus_with_stock(almacenId)
    body = JSON.parse(response.body)
    #puts body
    case response.code
      when 429
        GetProductsWithStockJob.set(wait: ENV["SERVER_RATE_LIMIT_TIME"].to_i.seconds).perform_later(almacenId)
        cache_response = $redis.get(key)
        if cache_response.nil?
          return nil
        end
        return JSON.load(cache_response)
    end

    $redis.set(fast_key, body.to_json)
    $redis.expire(fast_key, ENV["FAST_CACHE_EXPIRE_TIME"].to_i.seconds.to_i)

    $redis.set(key, body.to_json)
    $redis.expire(key, ENV["NORMAL_CACHE_EXPIRE_TIME"].to_i.seconds.to_i)
    return body
  end
end
