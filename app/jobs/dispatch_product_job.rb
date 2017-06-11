class DispatchProductJob < ApplicationJob
  queue_as :default

  def despachar_stock(producto_id, direccion, precio, oc)
    req_params = {
        :productoId => producto_id,
        :direccion => direccion,
        :precio => precio,
        :oc => oc,
      }
    auth_params = {
        :productoId => producto_id,
        :direccion => direccion,
        :precio => precio,
        :oc => oc,
      }
    return HTTParty.delete(
      ENV['CENTRAL_SERVER_URL'] + '/bodega/stock', 
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header('DELETE', auth_params) }
      );
  end

  def perform(sku, producto_id, from_store_house_id, direccion, precio, oc)
    $redis.del('get_skus_with_stock:' + from_store_house_id)
    response = despachar_stock(producto_id, direccion, precio, oc)
    puts 'Moviendo'
    puts response.code
    puts response.body
    #puts response
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
        :header => response.header,
    }
  end
end
