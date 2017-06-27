class UpdatePurchaseOrderWorker < ApplicationWorker
  sidekiq_options queue: 'critical'

  def perform(po_id)
    purchase_order = PurchaseOrder.find_by(po_id: po_id)
    if purchase_order != nil
      server = self.get_purchase_order(purchase_order.po_id)
      if server[:code] == 200
        body = server[:body]
        server_quantity_dispatched = body[:cantidadDespachada]
        quantity_dispatched = purchase_order.quantity_dispatched
        if purchase_order.is_b2b
          if purchase_order.server_quantity_dispatched < server_quantity_dispatched
            quantity_dispatched = server_quantity_dispatched
          end
        else
          quantity_dispatched = server_quantity_dispatched
        end
        purchase_order.update(status: body[:estado],
                              rejected_reason: body[:rechazo],
                              cancelled_reason: body[:anulacion],
                              quantity_dispatched: quantity_dispatched,
                              server_quantity_dispatched: server_quantity_dispatched,
        )
      else
        #purchase_order.destroy
      end
    end
  end
end