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


  def perform(monto, origen, destino)
    response = transferir(monto, origen, destino)
    puts response.body
    puts response.code
    body = JSON.parse(response.body, symbolize_names: true)
    case response.code
      when 429 # falta numero de error correcto
        Transaction.create(
            _id: 'error',
            amount: monto,
            origin: origen,
            destination: destino,
        )
        return nil
    end
    Transaction.create(
        _id: body[:_id],
        amount: body[:monto],
        origin: body[:cuenta_origen],
        destination: body[:cuenta_destino],
        created_at: DateTime.parse(body[:created_at]),#DateTime.parse(Time.at(body[:created_at] / 1000.0).to_s),
        updated_at: DateTime.parse(body[:updated_at]), #DateTime.parse(Time.at(body[:updated_at] / 1000.0).to_s),
    )
    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end

end