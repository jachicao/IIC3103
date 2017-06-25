class CreateBillWorker < ApplicationWorker

  def perform(cliente, total)
    req_params = {
        :proveedor => ENV['GROUP_ID'],
        :cliente => cliente,
        :total => total,
    }
    response = HTTParty.put(
        ENV['CENTRAL_SERVER_URL'] + '/sii/boleta',
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json'}
    )
    body = JSON.parse(response.body, symbolize_names: true)
    Invoice.create_new(body[:_id])
    return {
        :body => body,
        :code => response.code,
    }
  end
end
