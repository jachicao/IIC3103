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
    response = anular_orden_de_compra(id, anulacion)
    body = JSON.parse(response.body, symbolize_names: true)

    if body.kind_of?(Array)
      body = body.first
    end

    puts body
    puts response.code

    purchase_order = PurchaseOrder.find_by(po_id: id)
    if purchase_order != nil
      purchase_order.update_properties_async
    end

    return {
        :body => body,
        :code => response.code,
    }
  end
end
