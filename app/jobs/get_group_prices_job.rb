class GetGroupPricesJob < ApplicationJob
  queue_as :default

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
    response = obtener_precios(group_number)
    body = JSON.parse(response.body, symbolize_names: true)
    puts body
    return {
        :body => body,
        :code =>  response.code,
    }
  end
end
