class RejectServerPurchaseOrderJob < ApplicationJob
  queue_as :default

  def rechazar_orden_de_compra(id, rechazo)
    req_params = {
        :id => id,
        :_id => id,
        :rechazo => rechazo
      }
    return HTTParty.post(
      ENV['CENTRAL_SERVER_URL'] + '/oc/rechazar/' + id, 
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json' }
      )
  end

  def perform(id, rechazo)
    $redis.del('obtener_orden_de_compra:' + id)
  	response = rechazar_orden_de_compra(id, rechazo)
    puts response.body
    puts response.code
    return {
        :body => JSON.parse(response.body, symbolize_names: true),
        :code =>  response.code,
        :header => response.header,
    }
  end
end
