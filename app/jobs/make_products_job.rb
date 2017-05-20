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
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header('PUT', auth_params) }
      )
  end

  def perform(sku, cantidad, trxId)
    response = producir_stock(sku, cantidad, trxId)
    #puts response
    body = JSON.parse(response.body, symbolize_names: true)
    case response.code
      when 429
        #MakeProductsJob.set(wait: 90.seconds).perform_later(sku, cantidad, trxId)
        return nil
    end
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
    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end
end
