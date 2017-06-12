class CancelServerPurchaseOrderJob < ApplicationJob

  def anular_orden_de_compra(id, anulacion)
    req_params = {
        :_id => id,
        :id => id,
        :anulacion => anulacion,
      }
      puts req_params
    return HTTParty.delete(
      ENV['CENTRAL_SERVER_URL'] + '/oc/anular/' + id,
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json' }
      )
  end

  def perform(id, anulacion)
    $redis.del('obtener_orden_de_compra:' + id)
    response = anular_orden_de_compra(id, anulacion)
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
