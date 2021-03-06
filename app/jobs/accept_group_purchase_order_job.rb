class AcceptGroupPurchaseOrderJob < ApplicationJob

  def aceptar_orden_de_compra(group_number, id)
    producer = Producer.find_by(group_number: group_number)
    req_params = {
    }
    url = producer.get_api_url + '/purchase_orders/' + id + '/accepted'
    if producer.use_rest_client
      begin
        return RestClient.patch(url,
                                req_params.to_json,
                                { content_type: :json, accept: :json, authorization: producer.get_access_token, 'X-ACCESS-TOKEN' => producer.get_access_token })
      rescue RestClient::ExceptionWithResponse => e
        return e.response
      end
    else
      return HTTParty.patch(
          url,
          :body => req_params,
          :headers => { content_type: 'application/json', accept: 'application/json', authorization: producer.get_access_token, 'X-ACCESS-TOKEN' => producer.get_access_token }
      )
    end
  end

  def perform(group_number, id)
    response = aceptar_orden_de_compra(group_number, id)
    puts response.body
    return {
        :body => response.body,
        :code => response.code,
    }
  end
end
