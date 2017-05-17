class AcceptGroupPurchaseOrderJob < ApplicationJob
  queue_as :default

  def aceptar_orden_de_compra(group_number, id)
    group_server_url = (ENV['GROUPS_SERVER_URL'] % [group_number])
    req_params = {
    }
    return HTTParty.patch(
        group_server_url + '/api/purchase_orders/' + id + '/accepted',
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: ENV['GROUP_ID'] }
    )
  end

  def perform(group_number, id)
    response = aceptar_orden_de_compra(group_number, id)
    body = JSON.parse(response.body)
    #puts body
    case response.code
      when 429
        AcceptGroupPurchaseOrderJob.set(wait: 90.seconds).perform_later(group_number, id)
        return nil
    end
    return body
  end
end
