class AcceptServerPurchaseOrderJob < ApplicationJob
  queue_as :default

  def recepcionar_orden_de_compra(id)
    req_params = {
        :_id => id,
        :id => id,
      }
    return HTTParty.post(
      ENV['CENTRAL_SERVER_URL'] + '/oc/recepcionar/' + id, 
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json' }
      )
  end

  def perform(id)
    $redis.del('obtener_orden_de_compra:' + id)
  	response = recepcionar_orden_de_compra(id)
    puts response.body
    puts response.code
    return {
        :body => JSON.parse(response.body, symbolize_names: true),
        :code =>  response.code,
        :header => response.header,
    }
  end
end
