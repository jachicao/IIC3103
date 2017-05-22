class AcceptGroupPurchaseOrderJob < ApplicationJob
  queue_as :default

  def aceptar_orden_de_compra(group_number, id)
    group_server_url = (ENV['GROUPS_SERVER_URL'] % [group_number])
    req_params = {
    }
    puts group_server_url + ENV['API_URL_GROUP_' + group_number.to_s] + '/purchase_orders/' + id + '/accepted'
    return HTTParty.patch(
        group_server_url + ENV['API_URL_GROUP_' + group_number.to_s] + '/purchase_orders/' + id + '/accepted',
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: ENV['GROUP_ID'], x_access_token: ENV['GROUP_ID']}
    )
  end

  def perform(group_number, id)
    response = aceptar_orden_de_compra(group_number, id)
    puts response.code
    #puts response.body
    puts response.header['Content-Type']
    return {
        :body => JSON.parse(response.body, symbolize_names: true),
        :code =>  response.code,
        :header => response.header,
    }
  end
end
