class MoveProductInternallyJob < ApplicationJob
  queue_as :default

  def mover_stock(productoId, almacenId)
    req_params = { 
        :productoId => productoId,
        :almacenId => almacenId,
      }
    auth_params = {
        :productoId => productoId,
        :almacenId => almacenId,
      }
    return HTTParty.post(
      ENV['CENTRAL_SERVER_URL'] + '/bodega/moveStock', 
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header("POST", auth_params) }
      )
  end

  def perform(productoId, almacenId)
    response = mover_stock(productoId, almacenId)
    body = JSON.parse(response.body)
    #puts body
    case response.code
      when 429
        MoveProductInternallyJob.set(wait: 90.seconds).perform_later(productoId, almacenId)
        return nil
    end
    return body
  end
end
