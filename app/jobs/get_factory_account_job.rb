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
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("GET", auth_params) }
      )
  end

  def perform()
    response = get_cuenta_fabrica()
    body = JSON.parse(response.body)
    #puts body
    case response.code
      when 429
        GetFactoryAccountJob.set(wait: 90.seconds).perform_later()
        return nil
    end
    return body
  end
end
