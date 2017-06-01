class AcceptPurchaseOrdersWorker
  include Sidekiq::Worker

  def perform(purchase_order_id)

    server_purchase_order = GetPurchaseOrderJob.perform_now(purchase_order_id)
    response = server_purchase_order[:body].first
    group_number = Producer.all.find_by(producer_id: response[:cliente]).group_number
    sku = response[:sku]
    cuantity = response[:cantidad]
    price = response[:precioUnitario]
    product_in_sale = ProductInSale.do_i_produce(sku)
    purchase_order = PurchaseOrder.aññ.find_by(po_id: purchase_order_id)

    if product_in_sale =! nil

      if product_in_sale.get_price() < price
        RejectGroupPurchaseOrderJob.perform_now(group_number, purchase_order_id, "Precio Incorrecto")
        RejectServerPurchaseOrderJob.perform_now(purchase_order_id, "Precio Incorrecto")
        purchase_order.destroy
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

        if time_analysis.to_f.hours == 0
          purchase_order.dispatch_order(sku, cuantity, price)
        end

      else
        RejectGroupPurchaseOrderJob.perform_now(group_number, purchase_order_id, "Tiempo insuficiente")
        RejectServerPurchaseOrderJob.perform_now(purchase_order_id, "Tiempo insuficiente")
        purchase_order.destroy
      end

    end

  else
    RejectGroupPurchaseOrderJob.perform_now(group_number, purchase_order_id, "SKU incorrecta")
    RejectServerPurchaseOrderJob.perform_now(purchase_order_id,"SKU incorrecta")
    purchase_order.destroy
  end

end
