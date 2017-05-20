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
    puts response.body
    return {
        :body => JSON.parse(response.body, symbolize_names: true),
        :code =>  response.code,
        :header => response.header,
    }
  end
end
