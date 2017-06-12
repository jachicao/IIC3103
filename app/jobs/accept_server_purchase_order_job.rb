class AcceptServerPurchaseOrderJob < ApplicationJob

  def recepcionar_orden_de_compra(id)
    req_params = {
        :_id => id,
        :id => id,
    }
    return HTTParty.post(
        ENV['CENTRAL_SERVER_URL'] + '/oc/recepcionar/' + id,
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json' }
    )
  end

  def perform(id)
    $redis.del('obtener_orden_de_compra:' + id)
    response = recepcionar_orden_de_compra(id)
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
