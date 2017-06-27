class CreateServerInvoiceJob < ApplicationJob


  def perform(id)
    req_params = {
        :oc => id,
    }
    url = ENV['CENTRAL_SERVER_URL'] + '/sii/'
    response = HTTParty.put(
        url,
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json'}
    )
    puts url
    puts response.body
    body = JSON.parse(response.body, symbolize_names: true)
    return {
        :body => body,
        :code => response.code,
    }
  end
end
