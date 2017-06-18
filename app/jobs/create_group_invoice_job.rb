class CreateGroupInvoiceJob < ApplicationJob

  def crear_factura(id, group_number, bank_id)
    producer = Producer.find_by(group_number: group_number)
    req_params = {
      :bank_account => bank_id,
    }
    url = producer.get_api_url + '/invoices/' + id
    case group_number
      when 2
        begin
          return RestClient.put(url,
                                req_params.to_json,
                                { content_type: :json, accept: :json, authorization: producer.get_access_token, 'X-ACCESS-TOKEN' => producer.get_access_token })
        rescue RestClient::ExceptionWithResponse => e
          return e.response
        end
    end
    return HTTParty.put(
        url,
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: producer.get_access_token, 'X-ACCESS-TOKEN' => producer.get_access_token }
    )
  end

  def perform(id, group_number, bank_id)
    response = crear_factura(id, group_number, bank_id)
    puts response.body
    return {
        :body => response.body,
        :code =>  response.code,
    }
  end
end
