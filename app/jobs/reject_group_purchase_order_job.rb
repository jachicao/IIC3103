class RejectGroupPurchaseOrderJob < ApplicationJob
  queue_as :default

  def rechazar_orden_de_compra(group_number, id, cause)
    group_server_url = (ENV['GROUPS_SERVER_URL'] % [group_number])
    req_params = {
    	cause: cause,
    }
    return HTTParty.patch(
        group_server_url + '/api/purchase_orders/' + id + '/rejected',
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: ENV['GROUP_ID'] }
    )
  end

  def perform(group_number, id, cause)
    response = rechazar_orden_de_compra(group_number, id, cause)
    #puts response
    return {
        :body => JSON.parse(response.body, symbolize_names: true),
        :code =>  response.code,
        :header => response.header,
    }
  end
end
