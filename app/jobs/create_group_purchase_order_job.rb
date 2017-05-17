class CreateGroupPurchaseOrderJob < ApplicationJob
  queue_as :default

  def crear_orden_de_compra(group_number, id, payment_method, id_store_reception)
    group_server_url = (ENV['GROUPS_SERVER_URL'] % [group_number])
    req_params = {
        payment_method: payment_method,
        id_store_reception: id_store_reception,
    }
    return HTTParty.put(
        group_server_url + '/api/purchase_orders/' + id,
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: ENV['GROUP_ID'] }
    )
  end

  def perform(group_number, id, payment_method, id_store_reception)
    response = crear_orden_de_compra(group_number, id, payment_method, id_store_reception)
    body = JSON.parse(response.body)
    #puts body
    case response.code
      when 429
        CreateGroupPurchaseOrderJob.set(wait: 90.seconds).perform_later(group_number, id, payment_method, id_store_reception)
        return nil
    end
    return body
  end
end
