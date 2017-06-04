class CreateServerInvoiceJob < ApplicationJob
  queue_as :default

  def emitir_factura(id)
    req_params = {
        :oc => id,
    }
    return HTTParty.put(
        ENV['CENTRAL_SERVER_URL'] + '/sii',
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json'}
    )
  end

  def perform(id)
    response = emitir_factura(id)
    puts response.body
    body = JSON.parse(response.body, symbolize_names: true)
    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end
end
