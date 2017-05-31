class CreateGroupPurchaseOrderJob < ApplicationJob
  queue_as :default

  #grupo2: ok
  #grupo3: no, {"status":404,"error":"Not Found"}
  #grupo4: no, 'SyntaxError at /api/purchase_orders/592e0898b0cb2100049756a4
  #grupo5: no, {"status":500,"error":"Internal Server Error"}
  #grupo6: no, {"status":400,"error":"Bad Request"}
  #grupo7: ok
  #grupo8: no, No route matches [PUT] /purchase_orders/592e08dfb0cb2100049756a5
  def crear_orden_de_compra(group_number, id, payment_method, id_store_reception)
    group_server_url = (ENV['GROUPS_SERVER_URL'] % [group_number]) + ENV['API_URL_GROUP_' + group_number.to_s]
    req_params = {
        :payment_method => payment_method,
        :id_store_reception => id_store_reception,
    }
    url = group_server_url + '/purchase_orders/' + id
    puts url
    puts req_params
    case group_number
      when 2
        begin
          return RestClient.put(url,
                                req_params.to_json,
                                { content_type: :json, accept: :json, authorization: ENV['GROUP_ID'], 'X-ACCESS-TOKEN': ENV['GROUP_ID'] })
        rescue RestClient::ExceptionWithResponse => e
          return e.response
        end
      when 3
        req_params[:payment] = payment_method #Indica si el pago será al contado, cuotas o crédito.
      when 4

      when 5
        req_params[:payment_method] = 'contado' # Método de pago (contado/cuotas)
        req_params[:payment_option] = '1' # Permite definir las condiciones del método de pago. Para crédito se quisiera poder indicar la cantidad de días del crédito. Para cuotas, la cantidad de cuotas.
      when 6
        req_params[:payment_method] = 'entrega' # "entrega,credito,cuotas"
        req_params[:payment_option] = 1
      when 8

    end
    return HTTParty.put(
        url,
        :body => req_params,
        :headers => { content_type: 'application/json', accept: 'application/json', authorization: ENV['GROUP_ID'], 'X-ACCESS-TOKEN': ENV['GROUP_ID'] }
    )
  end

  def perform(group_number, id, payment_method, id_store_reception)
    response = crear_orden_de_compra(group_number, id, payment_method, id_store_reception)
    puts response.code
    puts response.body
    return {
        :body => JSON.parse(response.body, symbolize_names: true),
        :code =>  response.code,
    }
  end
end
