class UpdateAllPurchaseOrdersWorker < ApplicationWorker

  def perform(*args)
    PurchaseOrder.all.each do |purchase_order|
      if purchase_order.is_rejected or purchase_order.is_cancelled or purchase_order.is_completed
        UpdatePurchaseOrderWorker.perform_async(purchase_order.po_id)
      end
    end
  end
end
