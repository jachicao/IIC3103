class MakeBillJob < ApplicationJob
  queue_as :default

  def crear_boleta(proveedor, cliente, total)
    req_params = {
        :proveedor => proveedor,
        :cliente => cliente,
        :total => total,
    }
    return HTTParty.put(
        ENV['CENTRAL_SERVER_URL'] + '/sii/boleta',
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json'}
    )
  end

  def perform(proveedor, cliente, total)
    response = crear_boleta(proveedor, cliente, total)
    puts response.body
    body = JSON.parse(response.body, symbolize_names: true)
    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end
end
