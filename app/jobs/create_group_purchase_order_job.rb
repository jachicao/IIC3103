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
    #puts response
    return {
        :body => JSON.parse(response.body, symbolize_names: true),
        :code =>  response.code,
        :header => response.header,
    }
  end
end
