class MoveProductToDirectionWorker < ApplicationWorker
  sidekiq_options queue: 'low'

  def perform(sku, product_id, from_store_house_id, direction, price, po_id)
    req_params = {
        :productoId => product_id,
        :direccion => direction,
        :precio => price,
        :oc => po_id,
    }
    auth_params = {
        :productoId => product_id,
        :direccion => direction,
        :precio => price,
        :oc => po_id,
    }
    response = HTTParty.delete(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/stock',
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: self.get_auth_header('DELETE', auth_params) }
    )
    if response.code == 200
      from_store_house = StoreHouse.find_by(_id: from_store_house_id)
      from_store_house.stocks.each do |s|
        if s.product.sku == sku
          s.update(quantity: s.quantity - 1)
        end
      end
    end
    body = JSON.parse(response.body, symbolize_names: true)
    return {
        :body => body,
        :code =>  response.code,
    }
  end
end