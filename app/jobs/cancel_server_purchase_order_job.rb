class CancelServerPurchaseOrderJob < ApplicationJob
  queue_as :default

  def anular_orden_de_compra(id, anulacion)
    req_params = {
        :id => id,
        :anulacion => anulacion,
      }
    return HTTParty.post(
      ENV['CENTRAL_SERVER_URL'] + '/oc/anular/' + id, 
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json' }
      )
  end

  def perform(id, anulacion)
    response = anular_orden_de_compra(id, anulacion)
    #puts response
    return {
        :body => JSON.parse(response.body, symbolize_names: true),
        :code =>  response.code,
        :header => response.header,
    }
  end
end
