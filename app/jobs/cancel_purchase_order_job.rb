class CancelPurchaseOrderJob < ApplicationJob
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
    body = JSON.parse(response.body)
    #puts body
    case response.code
      when 429
        CancelPurchaseOrderJob.set(wait: 90.seconds).perform_later(id, anulacion)
        return nil
    end
    return body
  end
end
