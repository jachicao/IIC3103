class UpdateAllPurchaseOrdersWorker < ApplicationWorker

  def perform(*args)
    PurchaseOrder.all.each do |purchase_order|
      UpdatePurchaseOrderWorker.perform_async(purchase_order.po_id)
    end
  end
end
