class RejectServerPurchaseOrderJob < ApplicationJob
  queue_as :default

  def rechazar_orden_de_compra(id, rechazo)
    req_params = {
        :id => id,
        :_id => id,
        :rechazo => rechazo
      }
    return HTTParty.post(
      ENV['CENTRAL_SERVER_URL'] + '/oc/rechazar/' + id, 
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json' }
      )
  end

  def perform(id, rechazo)
    $redis.del('obtener_orden_de_compra:' + id)
  	response = rechazar_orden_de_compra(id, rechazo)
    body = JSON.parse(response.body, symbolize_names: true)

    if body.kind_of?(Array)
      body = body.first
    end

    puts body
    puts response.code
    if response.code == 200
      purchase_order = PurchaseOrder.find_by(po_id: id)
      if purchase_order != nil
        purchase_order.update(status: body[:estado],
                              rejected_reason: body[:rechazo],
                              cancelled_reason: body[:anulacion],
        )
      end
    end
    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end
end
