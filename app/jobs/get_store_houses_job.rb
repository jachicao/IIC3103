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
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header('GET', auth_params) }
      )
  end

  def perform()
    key = 'get_almacenes'
    cache_response = $redis.get(key)
    if cache_response != nil
      return {
          :body => JSON.parse(cache_response, symbolize_names: true)
      }
    end

    response = get_almacenes()
    #puts response
    body = JSON.parse(response.body, symbolize_names: true)
    case response.code
      when 429
        #GetStoreHousesJob.set(wait: ENV['SERVER_RATE_LIMIT_TIME'].to_i.seconds).perform_later()
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
