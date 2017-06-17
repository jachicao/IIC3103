class ApplicationWorker
  include Sidekiq::Worker

  def get_auth_header(request_type, auth_params)
    temp_string = request_type
    auth_params.each do |k,v|
      temp_string.concat(v.to_s)
    end
    return 'INTEGRACION grupo' + ENV['GROUP_NUMBER'] + ':' + Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), ENV['STORE_HOUSE_PASSWORD'], temp_string))
  end

  def get_factory_account
    req_params = {

    }
    auth_params = {

    }
    response = HTTParty.get(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/fabrica/getCuenta',
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: self.get_auth_header('GET', auth_params) }
    )
    if response.code == 429
      sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
      return self.get_factory_account
    end
    body = JSON.parse(response.body, symbolize_names: true)
    return {
        :body => body,
        :code =>  response.code,
    }
  end

  def make_product(sku, cantidad, trx_id)
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
    response = HTTParty.put(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/fabrica/fabricar',
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: get_auth_header('PUT', auth_params) }
    )
    case response.code
      when 200

      when 429
        sleep(ENV['SERVER_RATE_LIMIT_TIME'].to_i)
        return self.make_product(sku, cantidad, trx_id)
      else
        return nil
    end
    body = JSON.parse(response.body, symbolize_names: true)

    product = Product.find_by(sku: sku)
    unit_lote = (cantidad.to_f / product.lote.to_f).ceil
    product.ingredients.each do |ingredient|
      ingredient.item.stocks.each do |s|
        if s.store_house.despacho
          s.update(quantity: [s.quantity - unit_lote * ingredient.quantity, 0].max)
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
    }
  end

  def transfer_money(destino, monto)
    origen = Bank.get_bank_id
    req_params = {
        :monto => monto,
        :origen => origen,
        :destino => destino,
    }
    response = HTTParty.put(
        ENV['CENTRAL_SERVER_URL'] + '/banco/trx',
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json'}
    )
    case response.code
      when 200..226
      else
        FailedTransaction.create(
            origin: origen,
            destination: destino,
            amount: monto,
        )
        sleep(5)
        return self.transfer_money(destino, monto)
    end
    body = JSON.parse(response.body, symbolize_names: true)
    return {
        :body => body,
        :code =>  response.code,
    }
  end

  def get_store_houses
    req_params = {
    }
    auth_params = {
    }
    response = HTTParty.get(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/almacenes',
        :query => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: self.get_auth_header('GET', auth_params) }
    )
    case response.code
      when 429
        return nil
    end
    body = JSON.parse(response.body, symbolize_names: true)

    return {
        :body => body,
        :code =>  response.code,
    }
  end

  def get_products_with_stock(store_house_id)
    req_params = {
        :almacenId => store_house_id,
    }
    auth_params = {
        :almacenId => store_house_id,
    }

    response = HTTParty.get(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/skusWithStock',
        :query => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: self.get_auth_header('GET', auth_params) }
    )
    case response.code
      when 429
        return nil
    end
    body = JSON.parse(response.body, symbolize_names: true)

    return {
        :body => body,
        :code =>  response.code,
    }
  end

  def get_product_stock(store_house_id, sku, limit)
    req_params = {
        :almacenId => store_house_id,
        :sku => sku,
        :limit => limit,
    }
    auth_params = {
        :almacenId => store_house_id,
        :sku => sku,
    }
    response = HTTParty.get(
        ENV['CENTRAL_SERVER_URL'] + '/bodega/stock',
        :query => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: self.get_auth_header('GET', auth_params) }
    )
    case response.code
      when 429
        return nil
    end
    body = JSON.parse(response.body, symbolize_names: true)
    return {
        :body => body,
        :code =>  response.code,
        :header => response.header,
    }
  end

  def get_purchase_order(po_id)
    req_params = {

    }
    response = HTTParty.get(
        ENV['CENTRAL_SERVER_URL'] + '/oc/obtener/' + po_id,
        :query => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json' }
    )
    body = JSON.parse(response.body, symbolize_names: true)

    if body.kind_of?(Array)
      body = body.first
    end

    return {
        :body => body,
        :code => response.code,
    }
  end

  def get_invoice(_id)
    req_params = {

    }
    response = HTTParty.get(
        ENV['CENTRAL_SERVER_URL'] + '/sii/' + _id,
        :query => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json'}
    )
    body = JSON.parse(response.body, symbolize_names: true)
    if body.kind_of?(Array)
      body = body.first
    end

    return {
        :body => body,
        :code =>  response.code,
    }
  end

  def get_group_prices(group_number)
    url = (ENV['GROUPS_SERVER_URL'] % [group_number]) + '/api/publico/precios'
    req_params = {
    }
    response = HTTParty.get(
        url,
        :query => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: ENV['GROUP_ID'], 'X-ACCESS-TOKEN': ENV['GROUP_ID'] }
    )
    body = JSON.parse(response.body, symbolize_names: true)

    return {
        :body => body,
        :code =>  response.code,
    }
  end
end