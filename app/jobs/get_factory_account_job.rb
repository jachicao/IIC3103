class GetFactoryAccountJob < ApplicationJob
  queue_as :default

  def get_cuenta_fabrica()
    req_params = {

      }
    auth_params = {

      }
    return HTTParty.get(
      ENV['CENTRAL_SERVER_URL'] + '/bodega/fabrica/getCuenta', 
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header('GET', auth_params) }
      )
  end

  def perform()
    key = 'get_cuenta_fabrica'
    cache_response = $redis.get(key)
    if cache_response != nil
      return {
          :body => JSON.parse(cache_response, symbolize_names: true)
      }
    end
    response = get_cuenta_fabrica()
    #puts response
    body = JSON.parse(response.body, symbolize_names: true)
    case response.code
      when 429
        #GetFactoryAccountJob.set(wait: 90.seconds).perform_later()
        return nil
    end

    $redis.set(key, body.to_json)
    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end
end
