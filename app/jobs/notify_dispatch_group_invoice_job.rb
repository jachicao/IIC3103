class NotifyDispatchGroupInvoiceJob < ApplicationJob

  def factura_despachada(id, group_number)
    producer = Producer.find_by(group_number: group_number)
    req_params = {
    }
    url = producer.get_api_url + '/invoices/' + id + '/delivered'
    case group_number
      when 2
        begin
          return RestClient.patch(url,
                                  req_params.to_json,
                                  { content_type: :json, accept: :json, authorization: producer.get_access_token, 'X-ACCESS-TOKEN' => producer.get_access_token })
        rescue RestClient::ExceptionWithResponse => e
          return e.response
        end
    end
    return HTTParty.patch(
        url,
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: producer.get_access_token, 'X-ACCESS-TOKEN' => producer.get_access_token }
    )
  end

  def perform(id, group_number)
    response = factura_despachada(id, group_number)
    puts response.body
    return {
        :body => response.body,
        :code =>  response.code,
    }
  end
end
