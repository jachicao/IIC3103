class CreateConsumerPurchaseOrderWorker < ApplicationWorker

  def perform(bill_id, client, sku, delivery_date, quantity, unit_price)

    server = CreateServerPurchaseOrderJob.perform_now(
        client,
        ENV['GROUP_ID'],
        sku,
        delivery_date,
        quantity,
        unit_price,
        'b2c',
    )
    body = server[:body]
    purchase_order = PurchaseOrder.create_new(body[:_id])
    if purchase_order != nil
      purchase_order.update(bill_id: bill_id)
      purchase_order.accept
      return {
          :success => true,
          :server => server,
      }
    else
      return {
          :success => false,
          :server => server,
      }
    end
  end
end
