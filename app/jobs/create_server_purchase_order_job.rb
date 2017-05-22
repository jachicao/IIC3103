class CreateServerPurchaseOrderJob < ApplicationJob
  queue_as :default

  def crear_orden_de_compra(cliente, proveedor, sku, fechaEntrega, cantidad, precioUnitario, canal, notas)
    req_params = {
        :cliente => cliente,
        :proveedor => proveedor,
        :sku => sku,
        :fechaEntrega => fechaEntrega,
        :cantidad => cantidad.to_i,
        :precioUnitario => precioUnitario.to_i,
        :canal => canal,
        #:notas => notas,
      }
    return HTTParty.put(
      ENV['CENTRAL_SERVER_URL'] + '/oc/crear', 
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json' }
      )
  end

  def perform(cliente, proveedor, sku, fechaEntrega, cantidad, precioUnitario, canal, notas)
    response = crear_orden_de_compra(cliente, proveedor, sku, fechaEntrega, cantidad, precioUnitario, canal, notas)
    puts response.body
    puts response.code
    return {
        :body => JSON.parse(response.body, symbolize_names: true),
        :code =>  response.code,
        :header => response.header,
    }
  end
end
