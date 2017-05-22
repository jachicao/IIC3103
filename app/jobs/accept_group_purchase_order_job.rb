class AcceptGroupPurchaseOrderJob < ApplicationJob
  queue_as :default

  def aceptar_orden_de_compra(group_number, id)
    group_server_url = (ENV['GROUPS_SERVER_URL'] % [group_number]) + ENV['API_URL_GROUP_' + group_number.to_s]
    req_params = {
    }
    return HTTParty.patch(
        group_server_url + '/purchase_orders/' + id + '/accepted',
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: ENV['GROUP_ID'], 'X-ACCESS-TOKEN': ENV['GROUP_ID']}
    )
  end

  def perform(group_number, id)
    response = aceptar_orden_de_compra(group_number, id)
    return {
        :body => JSON.parse(response.body, symbolize_names: true),
        :code =>  response.code,
        :header => response.header,
    }
  end
end
