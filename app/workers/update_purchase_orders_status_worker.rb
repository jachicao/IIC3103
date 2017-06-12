class UpdatePurchaseOrdersStatusWorker < ApplicationWorker
  sidekiq_options queue: 'critical'

  def perform(*args)
    PurchaseOrder.all.each do |purchase_order|
      if purchase_order.is_rejected or purchase_order.is_cancelled
      else
        UpdatePurchaseOrderStatusWorker.perform_async(purchase_order.po_id)
      end
    end
  end
end
