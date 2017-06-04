class GetBankTransactionJob < ApplicationJob
  queue_as :default

  def obtener_transaccion(id)
    req_params = {

    }
    return HTTParty.get(
        ENV['CENTRAL_SERVER_URL'] + '/banco/trx/' + id,
        :query => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json'}
    )
  end

  def perform(id)
    response = obtener_transaccion(id)
    puts response.body
    body = JSON.parse(response.body, symbolize_names: true)
    return {
        :body => body,
        :code =>  response.code,
    }
  end
end
