class CreateBillJob < ApplicationJob
  queue_as :default

  def crear_boleta(cliente, total)
    req_params = {
        :proveedor => ENV['GROUP_ID'],
        :cliente => cliente,
        :total => total,
    }
    return HTTParty.put(
        ENV['CENTRAL_SERVER_URL'] + '/sii/boleta',
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json'}
    )
  end

  def perform(cliente, total)
    response = crear_boleta(cliente, total)
    puts response.body
    puts response.code
    body = JSON.parse(response.body, symbolize_names: true)
    Invoice.create(
        _id: body[:_id],
        supplier_id: body[:proveedor],
        client_id: body[:cliente],
        amount: body[:total],
        po_id: body[:oc],
        is_bill: true,
    )
    return {
        :body => body,
        :code =>  response.code,
    }
  end
end
