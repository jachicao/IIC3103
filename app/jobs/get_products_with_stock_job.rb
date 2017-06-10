class GetProductsWithStockJob < ApplicationJob
  queue_as :default

  def get_skus_with_stock(almacen_id)
    req_params = {
        :almacenId => almacen_id,
      }
    auth_params = {
        :almacenId => almacen_id,
      }
    return HTTParty.get(
      ENV['CENTRAL_SERVER_URL'] + '/bodega/skusWithStock', 
      :query => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header('GET', auth_params) }
      )
  end

  def perform(almacen_id)

    response = get_skus_with_stock(almacen_id)
    body = JSON.parse(response.body, symbolize_names: true)
    case response.code
      when 429
        #GetProductsWithStockJob.set(wait: ENV['SERVER_RATE_LIMIT_TIME'].to_i.seconds).perform_later(almacenId)
        return nil
    end

    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end
end
