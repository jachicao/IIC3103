class RejectPurchaseOrderJob < ApplicationJob
  queue_as :default

  def rechazar_orden_de_compra(id, rechazo)
    req_params = {
        :id => id,
        :rechazo => rechazo
      }
    return HTTParty.post(
      ENV['CENTRAL_SERVER_URL'] + '/oc/rechazar/' + id, 
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json' }
      )
  end

  def perform(id, rechazo)
  	response = rechazar_orden_de_compra(id, rechazo)
    body = JSON.parse(response.body)
    #puts body
    case response.code
      when 429
        RejectPurchaseOrderJob.set(wait: 90.seconds).perform_later(id, rechazo)
        return nil
    end
    return body
  end
end
