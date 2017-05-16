class MakeProductsWithoutPaymentJob < ApplicationJob
  queue_as :default

  def producir_stock_sin_pagar(sku, cantidad)
    req_params = {
        :sku => sku,
        :cantidad => cantidad,
      }
    auth_params = {
        :sku => sku,
        :cantidad => cantidad,
      }
    return HTTParty.put(
      ENV['CENTRAL_SERVER_URL'] + '/bodega/fabrica/fabricarSinPago', 
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("PUT", auth_params) }
      )
  end

  def perform(sku, cantidad)
    response = producir_stock_sin_pagar(sku, cantidad)
    body = JSON.parse(response.body)
    #puts body
    case response.code
      when 429
        MakeProductsWithoutPaymentJob.set(wait: 90.seconds).perform_later(sku, cantidad)
        return nil
    end
    return body
  end
end
