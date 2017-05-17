class AcceptPurchaseOrderJob < ApplicationJob
  queue_as :default

  def recepcionar_orden_de_compra(id)
    req_params = {
        :id => id,
      }
    return HTTParty.post(
      ENV['CENTRAL_SERVER_URL'] + '/oc/recepcionar/' + id, 
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json' }
      )
  end

  def perform(id)
  	response = recepcionar_orden_de_compra(id)
    body = JSON.parse(response.body)
    #puts body
    case response.code
      when 429
        AcceptPurchaseOrderJob.set(wait: 90.seconds).perform_later(id)
        return nil
    end
    return body
  end
end
