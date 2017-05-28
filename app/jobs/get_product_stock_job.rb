class GetProductStockJob < ApplicationJob
  queue_as :default

  def get_stock(almacen_id, sku, limit)
    req_params = {
        :almacenId => almacenId,
        :sku => sku,
        :limit => limit,
      }
    auth_params = {
        :almacenId => almacenId,
        :sku => sku,
      }
    return HTTParty.get(
      ENV['CENTRAL_SERVER_URL'] + '/bodega/stock', 
      :query => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header('GET', auth_params) }
      )
  end

  def perform(almacen_id, sku, limit)
    response = get_stock(almacen_id, sku, limit)
    #puts response
    body = JSON.parse(response.body, symbolize_names: true)
    case response.code
      when 429
        #GetProductStockJob.set(wait: ENV["SERVER_RATE_LIMIT_TIME"].to_i.seconds).perform_later(almacenId, sku, limit)
        return nil
    end
    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end
end
