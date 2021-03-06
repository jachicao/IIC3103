class GetBankTransactionsJob < ApplicationJob

  #GetBankTransactionsJob.perform_now(DateTime.now - 1, DateTime.now)
  def obtener_cartola(id, fecha_inicio, fecha_fin)
    req_params = {
      id: id,
      _id: id,
      fechaInicio: (fecha_inicio.to_f * 1000).to_i,
      fechaFin: (fecha_fin.to_f * 1000).to_i,
      limit: 99999,
    }
    return HTTParty.post(
        ENV['CENTRAL_SERVER_URL'] + '/banco/cartola/',
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json'}
    )
  end

  def perform(id, fecha_inicio, fecha_fin)
    key = 'obtener_cartola:' + id
    cache_response = $redis.get(key)
    if cache_response != nil
      return {
          :body => JSON.parse(cache_response, symbolize_names: true),
          :code => 200,
      }
    end
    response = obtener_cartola(id, fecha_inicio, fecha_fin)
    #puts response.body
    body = JSON.parse(response.body, symbolize_names: true)

    $redis.set(key, body.to_json)
    $redis.expire(key, ENV['CACHE_EXPIRE_TIME'].to_i.seconds.to_i)

    return {
        :body => body,
        :code => response.code,
    }
  end

end
