class UpdatePurchaseOrdersWorker < ApplicationWorker
  sidekiq_options queue: 'critical'

  def perform(*args)
    PurchaseOrder.all.each do |purchase_order|
      if purchase_order.is_rejected or purchase_order.is_cancelled or purchase_order.is_completed
      else
        UpdatePurchaseOrderWorker.perform_async(purchase_order.po_id, false)
      end
    end
  end
end
