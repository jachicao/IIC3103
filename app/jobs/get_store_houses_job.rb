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

    response = get_almacenes
    #puts response
    body = JSON.parse(response.body, symbolize_names: true)
    case response.code
      when 429
        #GetStoreHousesJob.set(wait: ENV['SERVER_RATE_LIMIT_TIME'].to_i.seconds).perform_later()
        return nil
    end

    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end
end
