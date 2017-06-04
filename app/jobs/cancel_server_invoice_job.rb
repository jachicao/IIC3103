class CancelServerInvoiceJob < ApplicationJob
  queue_as :default

  def anular_factura(id, motivo)
    req_params = {
        :id => id,
        :_id => id,
        :motivo => motivo,
    }
    return HTTParty.post(
        ENV['CENTRAL_SERVER_URL'] + '/sii/cancel',
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json'}
    )
  end

  def perform(id, motivo)
    response = anular_factura(id, motivo)
    puts response.body
    body = JSON.parse(response.body, symbolize_names: true)
    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end
end
