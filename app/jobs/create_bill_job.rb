class CreateBillJob < ApplicationJob

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
    invoice = Invoice.create_new(body[:_id])
    if invoice != nil
      invoice.update(is_bill: true)
    end
    return {
        :body => body,
        :code => response.code,
    }
  end
end
