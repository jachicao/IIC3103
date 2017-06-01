class GetFailedTransaction < ApplicationJob


  def get_transactions(origen, destino,  total)
    req_params = {
        :origen => origen,
        :destino => destino,
        :total => total,
    }
    return HTTParty.put(
        ENV['CENTRAL_SERVER_URL'] + '/banco/trx',
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json'}
    )
  end

  def perform(origen, destino, total)
    response = get_transactions(origen, destino, total)
    puts response.body
    puts response.code
    body = JSON.parse(response.body, symbolize_names: true)
    case
      when 429
        Failedtransactions.create(
            _id: "error",
            origin: body[:origen],
            destination: body[:destino],
            amount: body[:monto],
            )
          return nil
    end
  end

end
