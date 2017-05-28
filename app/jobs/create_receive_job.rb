class CreateReceiveJob < ApplicationJob

  def crear_boleta(proveedor, cliente, total)
    req_params = {
        :proveedor => proveedor,
        :cliente => cliente,
        :total => total,
    }
    return HTTParty.put(
        ENV['CENTRAL_SERVER_URL'] + 'sii/boleta',
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json'}
    )

  end

  def perform(proveedor, cliente, total)
    response = crear_boleta(proveedor, cliente, total)
    #puts response
    body = JSON.parse(response.body, symbolize_names: true)
    case response.code
      when 429 # falta numero de error correcto
        return nil
    end
    Invoice.create( 
        _id: body[:_id],
        supplier: body[:proveedor]
        client: body[:cliente]
        total_amount: body[:valor_total],
        tax: body[:IVA],
        status: body[:estado],
        po_id: body[:id_orden_de_compra],
        created_at: DateTime.parse(body[:created_at]),#DateTime.parse(Time.at(body[:created_at] / 1000.0).to_s),
        updated_at: DateTime.parse(body[:updated_at]), #DateTime.parse(Time.at(body[:updated_at] / 1000.0).to_s),
    )
    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end

end
