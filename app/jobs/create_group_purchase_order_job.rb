class CreateGroupPurchaseOrderJob < ApplicationJob

  #grupo2: ok
  #grupo3: ok, {\"status\":\"accepted\",\"bank_account\":\"5910c0910e42840004f6e68e\",\"id_invoice\":\"5950c5c4b326790004c61d67\"}","code":201}
  #grupo4: ok
  #grupo5: ok, {\"success\":\"Orden recibida exitosamente. Se procederá a despacho al momento de aceptar y notificar factura por enviar\"
  #grupo6: no, {"status":400,"error":"Bad Request"}
  #grupo7: ok
  #grupo8: ok
  def crear_orden_de_compra(group_number, id, payment_method, id_store_reception)
    producer = Producer.find_by(group_number: group_number)
    req_params = {
        :payment_method => payment_method,
        :id_store_reception => id_store_reception,
    }
    url = producer.get_api_url + '/purchase_orders/' + id
    puts url
    use_rest_client = producer.use_rest_client
    case group_number
      when 8
        req_params = [req_params]
        use_rest_client = true
    end
    if use_rest_client
      begin
        return RestClient.put(url,
                              req_params.to_json,
                              producer.get_headers)
      rescue RestClient::ExceptionWithResponse => e
        return e.response
      end
    else
      return HTTParty.put(
          url,
          :body => req_params,
          :headers => producer.get_headers
      )
    end
  end

  def perform(group_number, id, payment_method, id_store_reception)
    response = crear_orden_de_compra(group_number, id, payment_method, id_store_reception)
    body = response.body.force_encoding('UTF-8')
    puts 'GRUPO: ' + group_number.to_s + ' ' + body
    case response.code
      when 200..226
        body = JSON.parse(response.body, symbolize_names: true)
        case group_number
          when 3
            if body[:id_invoice] != nil
              invoice = Invoice.create_new(body[:id_invoice])
              if invoice != nil
                invoice.update(bank_id: body[:bank_account])
              end
            end
          when 6
            if body[:factura_id] != nil
              #invoice = Invoice.create_new(body[:factura_id])
            end
        end
    end
    return {
        :body => body,
        :code => response.code,
    }
  end
end
