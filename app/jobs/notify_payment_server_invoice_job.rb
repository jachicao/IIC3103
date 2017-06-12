class NotifyPaymentServerInvoiceJob < ApplicationJob

  def factura_pagada(id)
    req_params = {
      :id => id,
      :_id => id,
    }
    return HTTParty.post(
        ENV['CENTRAL_SERVER_URL'] + '/sii/pay',
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json'}
    )
  end

  def perform(id)
    response = factura_pagada(id)
    puts response.body
    body = JSON.parse(response.body, symbolize_names: true)
    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end
end
