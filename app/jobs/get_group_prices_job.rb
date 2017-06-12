class GetGroupPricesJob < ApplicationJob

  def obtener_precios(group_number)
    url = (ENV['GROUPS_SERVER_URL'] % [group_number]) + '/api/publico/precios'
    req_params = {
    }
    return HTTParty.get(
        url,
        :query => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: ENV['GROUP_ID'], 'X-ACCESS-TOKEN': ENV['GROUP_ID'] }
    )
  end

  def perform(group_number)
    key = 'obtener_precios:' + group_number.to_s
    #please... TODO
    if group_number == 6
      return {
          :body => [],
          :code => 200,
      }
    end
    cache_response = $redis.get(key)
    if cache_response != nil
      return {
          :body => JSON.parse(cache_response, symbolize_names: true),
          :code => 200,
      }
    end

    response = obtener_precios(group_number)
    body = JSON.parse(response.body, symbolize_names: true)

    $redis.set(key, body.to_json)
    $redis.expire(key, ENV['CACHE_EXPIRE_TIME'].to_i.seconds.to_i)

    return {
        :body => body,
        :code =>  response.code,
    }
  end
end
