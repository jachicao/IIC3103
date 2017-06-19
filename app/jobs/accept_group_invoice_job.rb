class AcceptGroupInvoiceJob < ApplicationJob

  def aceptar_factura(group_number, id)
    producer = Producer.find_by(group_number: group_number)
    req_params = {

    }
    url = producer.get_api_url + '/invoices/' + id + '/accepted'
    if producer.use_rest_client
      begin
        return RestClient.patch(url,
                                req_params.to_json,
                                { content_type: :json, accept: :json, 'X-ACCESS-TOKEN' => producer.get_access_token })
      rescue RestClient::ExceptionWithResponse => e
        return e.response
      end
    else
      return HTTParty.patch(
          url,
          :body => req_params,
          :headers => { content_type: 'application/json', accept: 'application/json', authorization: ENV['GROUP_ID'], 'X-ACCESS-TOKEN' => ENV['GROUP_ID'] }
      )
    end
  end

  def perform(group_number, id)
    response = aceptar_factura(group_number, id)
    puts response.body
    return {
        :body => response.body,
        :code => response.code,
    }
  end
end
