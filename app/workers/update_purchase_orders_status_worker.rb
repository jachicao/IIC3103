class UpdatePurchaseOrdersStatusWorker
  include Sidekiq::Worker

  def perform(*args)
    if $updating_purchase_orders != nil
      return nil
    end
    $updating_purchase_orders = true
    PurchaseOrder.all.each do |purchase_order|
      server = GetPurchaseOrderJob.perform_now(purchase_order.po_id)
      if server[:code] == 200
        body = server[:body]
        if body != nil
          purchase_order.update(status: body[:estado],
                                rejected_reason: body[:rechazo],
                                cancelled_reason: body[:anulacion],
          )
        else
          purchase_order.destroy
        end
      else
        purchase_order.destroy
      end
    end
    $updating_purchase_orders = nil
  end
end
