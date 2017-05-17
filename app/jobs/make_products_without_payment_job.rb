require 'date'

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
    puts body
    FactoryOrder.create(
      fo_id: body[:_id],
      sku: body[:sku],
      group: body[:grupo],
      dispatched: body[:despachado],
      quantity: body[:cantidad],
      created_at: Time.at(body[:created_at] / 1000.0).to_date,
      updated_at: Time.at(body[:updated_at] / 1000.0).to_date,
      available: Time.at(body[:disponible] / 1000.0).to_date,
      )
    case response.code
      when 429
        MakeProductsWithoutPaymentJob.set(wait: 90.seconds).perform_later(sku, cantidad)
        return nil
    end
    return body
  end
end
