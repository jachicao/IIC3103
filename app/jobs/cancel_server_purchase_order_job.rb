class CancelServerPurchaseOrderJob < ApplicationJob
  queue_as :default

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
    puts response.body
    puts response.code
    return {
        :body => JSON.parse(response.body, symbolize_names: true),
        :code =>  response.code,
        :header => response.header,
    }
  end
end
