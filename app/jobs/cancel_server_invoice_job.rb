class CancelServerInvoiceJob < ApplicationJob

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

    invoice = Invoice.find_by(_id: id)
    if invoice != nil
      invoice.update_properties_async
    end

    return {
        :body => body,
        :code => response.code,
    }
  end
end
