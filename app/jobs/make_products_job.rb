class MakeProductsJob < ApplicationJob
  queue_as :default

  def producir_stock(sku, cantidad, trxId)
    req_params = {
        :sku => sku,
        :cantidad => cantidad,
        :trxId => trxId,
      }
    auth_params = {
        :sku => sku,
        :cantidad => cantidad,
        :trxId => trxId,
      }
    return HTTParty.put(
      ENV['CENTRAL_SERVER_URL'] + '/bodega/fabrica/fabricar', 
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("PUT", auth_params) }
      )
  end

  def perform(sku, cantidad, trxId)
    response = producir_stock(sku, cantidad, trxId)
    body = JSON.parse(response.body)
    #puts body
    case response.code
      when 429
        MakeProductsJob.set(wait: 90.seconds).perform_later(sku, cantidad, trxId)
        return nil
    end
    return body
  end
end
