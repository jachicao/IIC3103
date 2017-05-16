class GetStoreHousesJob < ApplicationJob
  queue_as :default

  def get_almacenes()
    req_params = {
      }
    auth_params = {
      }
    return HTTParty.get(
      ENV['CENTRAL_SERVER_URL'] + '/bodega/almacenes', 
      :query => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("GET", auth_params) }
      )
  end

  def perform()
    fast_key = "fast:get_almacenes"
    fast_cache_response = $redis.get(fast_key)
    if fast_cache_response != nil
      return JSON.load(fast_cache_response)
    end

    key = "get_almacenes"
    response = get_almacenes()
    body = JSON.parse(response.body)
    #puts body
    case response.code
      when 429
        GetStoreHousesJob.set(wait: ENV["SERVER_RATE_LIMIT_TIME"].to_i.seconds).perform_later()
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
