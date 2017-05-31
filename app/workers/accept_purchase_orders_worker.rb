class AcceptPurchaseOrdersWorker
  include Sidekiq::Worker

  def perform(purchase_order_id)

    purchase_order = GetPurchaseOrderJob.perform_now(purchase_order_id
    response = purchase_order[:body].first
    group_number = Producer.all.find_by(producer_id: response[:cliente]).group_number
    sku = response[:sku]
    cuantity = response[:cantidad]
    price = response[:precioUnitario]
    product_in_sale = ProductInSale.do_i_produce(sku)
    
    if product_in_sale =! nil

      if product_in_sale.get_price(sku) < price
        RejectGroupPurchaseOrderJob.perform_now(group_number, purchase_order_id, "Precio Incorrecto")
        RejectServerPurchaseOrderJob.perform_now(purchase_order_id, "Precio Incorrecto")
      end

      product =  product_in_sale.product

      if product.ingredients.size > 0
        time_analysis = product.get_ingredients_analysis(cuantity)[:produce_time]
      else
        time_analysis = product.get_factory_analysis(cuantity)[:produce_time]
      end

      if (Time.now + time_analysis.to_f.hours).to_i * 1000 < deadline
        AcceptGroupPurchaseOrderJob.perform_now(group_number, purchase_order_id)
        AcceptServerPurchaseOrderJob.perform_now(purchase_order_id)
      else
        RejectGroupPurchaseOrderJob.perform_now(group_number, purchase_order_id, "Tiempo insuficiente")
        RejectServerPurchaseOrderJob.perform_now(purchase_order_id, "Tiempo insuficiente")
      end

    end

  else
    RejectGroupPurchaseOrderJob.perform_now(group_number, purchase_order_id, "SKU incorrecta")
    RejectServerPurchaseOrderJob.perform_now(purchase_order_id,"SKU incorrecta")
  end

end
