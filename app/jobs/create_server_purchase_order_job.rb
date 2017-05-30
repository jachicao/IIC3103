class CreateServerPurchaseOrderJob < ApplicationJob
  queue_as :default

  def crear_orden_de_compra(cliente, proveedor, sku, fecha_entrega, cantidad, precio_unitario, canal, notas)
    req_params = {
        :cliente => cliente,
        :proveedor => proveedor,
        :sku => sku,
        :fechaEntrega => fecha_entrega,
        :cantidad => cantidad,
        :precioUnitario => precio_unitario,
        :canal => canal,
        #:notas => notas,
      }
    return HTTParty.put(
      ENV['CENTRAL_SERVER_URL'] + '/oc/crear', 
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json' }
      )
  end

  def perform(cliente, proveedor, sku, fecha_entrega, cantidad, precio_unitario, canal, notas)
    response = crear_orden_de_compra(cliente, proveedor, sku, fecha_entrega, cantidad, precio_unitario, canal, notas)
    puts response.body
    puts response.code
    return {
        :body => JSON.parse(response.body, symbolize_names: true),
        :code =>  response.code,
        :header => response.header,
    }
  end
end
