class CreateGroupPurchaseOrderJob < ApplicationJob
  queue_as :default

  #grupo2: ok
  #grupo3: no, {"status":404,"error":"Not Found"}
  #grupo4: no, syntax error, unexpected end-of-input, expecting keyword_end
  #grupo5: no, {"status":500,"error":"Internal Server Error"}
  #grupo6: no, {"status":400,"error":"Bad Request"}
  #grupo7: ok
  #grupo8: no, No route matches [PUT] /purchase_orders/592e08dfb0cb2100049756a5
  def crear_orden_de_compra(group_number, id, payment_type, id_store_reception)
    group_server_url = (ENV['GROUPS_SERVER_URL'] % [group_number]) + ENV['API_URL_GROUP_' + group_number.to_s]
    req_params = {
        :payment_method => 'contra_factura',
        :id_store_reception => id_store_reception,
    }
    url = group_server_url + '/purchase_orders/' + id
    puts url
    case group_number
      when 2
        puts req_params
        begin
          return RestClient.put(url,
                                req_params.to_json,
                                { content_type: :json, accept: :json, authorization: ENV['GROUP_ID'], 'X-ACCESS-TOKEN': ENV['GROUP_ID'] })
        rescue RestClient::ExceptionWithResponse => e
          return e.response
        end
      when 3
        req_params[:payment] = payment_type #Indica si el pago será al contado, cuotas o crédito.
        req_params[:payment_option] = 0 #depende del payment elegido: 0 si es contado, n° de cuotas si es en cuotas y n° de días del crédito si es crédito.
      when 4

      when 5
        req_params[:payment_method] = payment_type # Método de pago (contado/cuotas)
        req_params[:payment_option] = '1' # Permite definir las condiciones del método de pago. Para crédito se quisiera poder indicar la cantidad de días del crédito. Para cuotas, la cantidad de cuotas.
      when 6
        req_params[:payment_method] = 'entrega' # "entrega,credito,cuotas"
        req_params[:payment_option] = 1
      when 8

    end
    puts req_params
    return HTTParty.put(
        url,
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: ENV['GROUP_ID'], 'X-ACCESS-TOKEN': ENV['GROUP_ID'] }
    )
  end

  def perform(group_number, id, payment_type, id_store_reception)
    response = crear_orden_de_compra(group_number, id, payment_type, id_store_reception)
    puts response.body
    return {
        :body => response.body,
        :code =>  response.code,
    }
  end
end
