class CreateServerPurchaseOrderJob < ApplicationJob

  def crear_orden_de_compra(proveedor, sku, fecha_entrega, cantidad, precio_unitario, canal, notas)
    req_params = {
        :cliente => ENV['GROUP_ID'],
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

  def perform(proveedor, sku, fecha_entrega, cantidad, precio_unitario, canal, notas)
    response = crear_orden_de_compra(proveedor, sku, fecha_entrega, cantidad, precio_unitario, canal, notas)
    puts response.body
    puts response.code
    return {
        :body => JSON.parse(response.body, symbolize_names: true),
        :code =>  response.code,
        :header => response.header,
    }
  end
end
