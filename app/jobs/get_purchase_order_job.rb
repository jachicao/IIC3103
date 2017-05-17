class GetPurchaseOrderJob < ApplicationJob
  queue_as :default

  def obtener_orden_de_compra(id)
    req_params = {
        :id => id,
        :_id => id,
      }
    return HTTParty.get(
      ENV['CENTRAL_SERVER_URL'] + '/oc/obtener/' + id, 
      :query => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json' }
      )
  end

  def perform(id)
    response = obtener_orden_de_compra(id)
    body = JSON.parse(response.body)
    #puts body
    case response.code
      when 429
        GetPurchaseOrderJob.set(wait: 90.seconds).perform_later(id)
        return nil
      when 404
        return 404;
    end
    return body
  end
end
