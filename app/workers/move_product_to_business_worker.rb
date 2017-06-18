class MoveProductToBusinessWorker < ApplicationWorker
  sidekiq_options queue: 'low'

  def perform(sku, product_id, from_store_house_id, to_store_house_id, price, po_id)
    req_params = {
        :productoId => product_id,
        :almacenId => to_store_house_id,
        :oc => po_id,
        :precio => price,
    }
    auth_params = {
        :productoId => product_id,
        :almacenId => to_store_house_id,
    }
    response = HTTParty.post(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/moveStockBodega',
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: self.get_auth_header('POST', auth_params) }
    )
    if response.code == 200
      from_store_house = StoreHouse.find_by(_id: from_store_house_id)
      from_store_house.stocks.each do |s|
        if s.product.sku == sku
          s.update(quantity: s.quantity - 1)
        end
      end
      purchase_order = PurchaseOrder.find_by(po_id: po_id)
      if purchase_order != nil
        purchase_order.update_quantity_dispatched
      end
    end
    body = JSON.parse(response.body, symbolize_names: true)
    return {
        :body => body,
        :code =>  response.code,
    }
  end
end