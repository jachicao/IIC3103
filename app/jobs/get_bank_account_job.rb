class GetBankAccountJob < ApplicationJob

  def obtener_cuenta(id)
    req_params = {

    }
    return HTTParty.get(
        ENV['CENTRAL_SERVER_URL'] + '/banco/cuenta/' + id,
        :query => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json'}
    )
  end

  def perform()
    response = obtener_cuenta(Bank.get_bank_id)
    #puts response.body
    body = JSON.parse(response.body, symbolize_names: true)
    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end
end
