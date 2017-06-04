class NotifyPaymentGroupInvoiceJob < ApplicationJob
  queue_as :default

  def factura_pagada(id, group_number, trx_id)
    group_server_url = (ENV['GROUPS_SERVER_URL'] % [group_number]) + ENV['API_URL_GROUP_' + group_number.to_s]
    req_params = {
        :id_transaction => trx_id
    }
    url = group_server_url + '/invoices/' + id + '/paid'
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

  def perform(id, group_number, trx_id)
    response = factura_pagada(id, group_number, trx_id)
    puts response.body
    return {
        :body => response.body,
        :code =>  response.code,
    }
  end
end
