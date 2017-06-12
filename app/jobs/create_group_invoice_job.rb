class CreateGroupInvoiceJob < ApplicationJob

  def crear_factura(id, group_number, bank_id)
    group_server_url = (ENV['GROUPS_SERVER_URL'] % [group_number]) + ENV['API_URL_GROUP_' + group_number.to_s]
    req_params = {
      :bank_account => bank_id,
    }
    url = group_server_url + '/invoices/' + id
    case group_number
      when 2
        begin
          return RestClient.put(url,
                                req_params.to_json,
                                { content_type: :json, accept: :json, authorization: ENV['GROUP_ID'], 'X-ACCESS-TOKEN' => ENV['GROUP_ID'] })
        rescue RestClient::ExceptionWithResponse => e
          return e.response
        end
    end
    return HTTParty.put(
        url,
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: ENV['GROUP_ID'], 'X-ACCESS-TOKEN' => ENV['GROUP_ID'] }
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
