class MakeProductsJob < ApplicationJob
  queue_as :default

  def producir_stock(sku, cantidad, trx_id)
    req_params = {
        :sku => sku,
        :cantidad => cantidad,
        :trxId => trx_id,
      }
    auth_params = {
        :sku => sku,
        :cantidad => cantidad,
        :trxId => trx_id,
      }
    return HTTParty.put(
      ENV['CENTRAL_SERVER_URL'] + '/bodega/fabrica/fabricar', 
      :body => req_params,
      :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header('PUT', auth_params) }
      )
  end

  def perform(sku, cantidad, trx_id)
    response = producir_stock(sku, cantidad, trx_id)
    #puts response
    body = JSON.parse(response.body, symbolize_names: true)
    puts response.body
    puts response.code
    case response.code
      when 200

      when 429
        MakeProductsJob.set(wait: 90.seconds).perform_later(sku, cantidad, trx_id)
        return nil
      else
        return nil
    end

    product = Product.find_by(sku: sku)
    unit_lote = (cantidad.to_f / product.lote.to_f).ceil
    product.ingredients.each do |ingredient|
      StoreHouse.all.each do |store_house|
        if store_house.despacho
          store_house.stocks.each do |s|
            if s.product.sku == sku
              s.update(quantity: s.quantity - unit_lote * ingredient.quantity)
            end
          end
        end
      end
    end

    FactoryOrder.create(
        fo_id: body[:_id],
        product: product,
        quantity: body[:cantidad],
        available: DateTime.parse(body[:disponible]),
    )
    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end
end
