class GetProductStockJob < ApplicationJob
  queue_as :default

  def get_stock(almacenId, sku)
    req_params = {
        :almacenId => almacenId,
        :sku => sku,
        :limit => 100,
      }
    auth_params = {
        :almacenId => almacenId,
        :sku => sku,
      }
    return HTTParty.get(
      ENV['CENTRAL_SERVER_URL'] + '/bodega/stock', 
      :query => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("GET", auth_params) }
      )
  end

  def perform(almacenId, sku)
    fast_key = "fast:get_stock:" + almacenId + ":" + sku
    fast_cache_response = $redis.get(fast_key)
    if fast_cache_response != nil
      return JSON.load(fast_cache_response)
    end

    key = "get_stock:" + almacenId + ":" + sku
    response = get_stock(almacenId, sku)
    body = JSON.parse(response.body)
    #puts body
    case response.code
      when 429
        GetProductStockJob.set(wait: ENV["SERVER_RATE_LIMIT_TIME"].to_i.seconds).perform_later(almacenId, sku)
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
