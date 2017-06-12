class GetInvoiceJob < ApplicationJob

  def get_factura(id)
    req_params = {

    }
    return HTTParty.get(
        ENV['CENTRAL_SERVER_URL'] + '/sii/' + id,
        :query => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json'}
    )
  end

  def perform(id)
    response = get_factura(id)
    #puts response.body
    #puts response.code

    body = JSON.parse(response.body, symbolize_names: true)
    if body.kind_of?(Array)
      body = body.first
    end

    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end
end
