class RejectGroupInvoiceJob < ApplicationJob
  queue_as :default

  def rechazar_factura(id, group_number, cause)
    group_server_url = (ENV['GROUPS_SERVER_URL'] % [group_number]) + ENV['API_URL_GROUP_' + group_number.to_s]
    req_params = {
        :cause => cause
    }
    url = group_server_url + '/invoices/' + id + '/rejected'
    case group_number
      when 2
        begin
          return RestClient.patch(url,
                                  req_params.to_json,
                                  { content_type: :json, accept: :json, authorization: ENV['GROUP_ID'], 'X-ACCESS-TOKEN' => ENV['GROUP_ID'] })
        rescue RestClient::ExceptionWithResponse => e
          return e.response
        end
    end
    return HTTParty.patch(
        url,
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: ENV['GROUP_ID'], 'X-ACCESS-TOKEN' => ENV['GROUP_ID'] }
    )

  end

  def perform(id, group_number, cause)
    response = rechazar_factura(id, group_number, cause)
    puts response.body
    return {
        :body => response.body,
        :code =>  response.code,
    }
  end
end
