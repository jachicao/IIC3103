class CreatePurchaseOrderJob < ApplicationJob
  queue_as :default

  def crear_orden_de_compra(cliente, proveedor, sku, fechaEntrega, cantidad, precioUnitario, canal, notas)
    req_params = {
        :cliente => cliente,
        :proveedor => proveedor,
        :sku => sku,
        :fechaEntrega => fechaEntrega,
        :cantidad => cantidad,
        :precioUnitario => canal,
        :notas => notas,
      }
    return HTTParty.put(
      ENV['CENTRAL_SERVER_URL'] + '/oc/crear', 
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json' }
      )
  end

  def perform(cliente, proveedor, sku, fechaEntrega, cantidad, precioUnitario, canal, notas)
    response = crear_orden_de_compra(cliente, proveedor, sku, fechaEntrega, cantidad, precioUnitario, canal, notas)
    body = JSON.parse(response.body)
    #puts body
    case response.code
      when 429
        CreatePurchaseOrderJob.set(wait: 90.seconds).perform_later(cliente, proveedor, sku, fechaEntrega, cantidad, precioUnitario, canal, notas)
        return nil
    end
    return body
  end
end
