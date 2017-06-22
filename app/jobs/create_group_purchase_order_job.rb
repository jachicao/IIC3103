class CreateGroupPurchaseOrderJob < ApplicationJob

  #grupo2: ok
  #grupo3: no, {"status":404,"error":"id de la Orden de Compra no existe"}
  #grupo4: ok
  #grupo5: no, {"error":"Orden de compra invalida"}
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
      when 3
        req_params[:payment] = payment_method #Indica si el pago será al contado, cuotas o crédito.
        req_params[:payment_option] = 0 #depende del payment elegido: 0 si es contado, n° de cuotas si es en cuotas y n° de días del crédito si es crédito.
      when 6
        req_params[:payment_method] = payment_method #'entrega' # "entrega,credito,cuotas"
        req_params[:payment_option] = 1
      when 8
        req_params = [req_params]
        use_rest_client = true
    end
    if use_rest_client
      begin
        return RestClient.put(url,
                              req_params.to_json,
                              { content_type: :json, accept: :json, authorization: producer.get_access_token, 'X-ACCESS-TOKEN' => producer.get_access_token })
      rescue RestClient::ExceptionWithResponse => e
        return e.response
      end
    else
      return HTTParty.put(
          url,
          :body => req_params,
          :headers => { content_type: 'application/json', accept: 'application/json', authorization: producer.get_access_token, 'X-ACCESS-TOKEN' => producer.get_access_token }
      )
    end
  end

  def perform(group_number, id, payment_method, id_store_reception)
    response = crear_orden_de_compra(group_number, id, payment_method, id_store_reception)
    body = response.body.force_encoding('UTF-8')
    puts 'GRUPO: ' + group_number.to_s + ' ' + body
    return {
        :body => body,
        :code => response.code,
    }
  end
end
