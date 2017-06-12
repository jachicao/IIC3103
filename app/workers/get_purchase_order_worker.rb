class GetPurchaseOrderWorker < ApplicationWorker

  def perform(po_id)
    return self.get_purchase_order(po_id)
  end
end
