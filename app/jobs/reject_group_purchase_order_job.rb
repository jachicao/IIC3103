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
    body = JSON.parse(response.body)
    #puts body
    case response.code
      when 429
        RejectGroupPurchaseOrderJob.set(wait: 90.seconds).perform_later(group_number, id, cause)
        return nil
    end
    return body
  end
end
