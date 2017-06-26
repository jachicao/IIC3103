class CreateGroupInvoiceJob < ApplicationJob

  def crear_factura(group_number, id)
    producer = Producer.find_by(group_number: group_number)
    req_params = {
      :bank_account => Bank.get_bank_id,
    }
    url = producer.get_api_url + '/invoices/' + id
    if producer.use_rest_client
      begin
        return RestClient.put(url,
                              req_params.to_json,
                              producer.get_headers)
      rescue RestClient::ExceptionWithResponse => e
        return e.response
      end
    else
      return HTTParty.put(
          url,
          :body => req_params,
          :headers => producer.get_headers
      )
    end
  end

  def perform(group_number, id)
    response = crear_factura(group_number, id)
    puts response.body
    return {
        :body => response.body,
        :code => response.code,
    }
  end
end
