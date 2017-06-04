class MakeBankTransactionJob < ApplicationJob

  def transferir(monto, origen, destino)
    req_params = {
        :monto => monto,
        :origen => origen,
        :destino => destino,
    }
    return HTTParty.put(
        ENV['CENTRAL_SERVER_URL'] + '/banco/trx',
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json'}
    )
  end


  def perform(destino, monto)
    origen = Bank.get_bank_id
    $redis.del('obtener_cartola')
    response = transferir(monto, origen, destino)
    puts response.body
    puts response.code
    body = JSON.parse(response.body, symbolize_names: true)
    case
      when 200..226
      else
        FailedTransaction.create(
                  origin: origen,
                  destination: destino,
                  amount: monto,
        )
        return nil
    end
    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end

end