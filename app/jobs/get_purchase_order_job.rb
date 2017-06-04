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
    body = JSON.parse(response.body, symbolize_names: true)

    if body.kind_of?(Array)
      body = body.first
    end

    return {
        :body => body,
        :code => response.code,
    }
  end
end
