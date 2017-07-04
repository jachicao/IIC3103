class UpdatePurchaseOrderWorker < ApplicationWorker
  sidekiq_options queue: 'critical'

  def perform(po_id)
    purchase_order = PurchaseOrder.find_by(po_id: po_id)
    if purchase_order != nil
      server = self.get_purchase_order(purchase_order.po_id)
      if server[:code] == 200
        body = server[:body]
        if body != nil
          quantity_dispatched = purchase_order.quantity_dispatched
          server_quantity_dispatched = body[:cantidadDespachada]
          if purchase_order.is_made_by_me
            quantity_dispatched = server_quantity_dispatched
          else
            if purchase_order.is_b2b
              if quantity_dispatched >= purchase_order.quantity
                if purchase_order.server_quantity_dispatched < server_quantity_dispatched
                  quantity_dispatched = server_quantity_dispatched
                end
              end
              if server_quantity_dispatched >= quantity_dispatched
                quantity_dispatched = server_quantity_dispatched
              end
            else
              quantity_dispatched = server_quantity_dispatched
            end
          end
          purchase_order.update(status: body[:estado],
                                rejected_reason: body[:rechazo],
                                cancelled_reason: body[:anulacion],
                                quantity_dispatched: quantity_dispatched,
                                server_quantity_dispatched: server_quantity_dispatched,
                                created_at: DateTime.parse(body[:created_at]),
                                updated_at: DateTime.parse(body[:updated_at]),
          )
        else
          #purchase_order.destroy
        end
      end
    end
  end
end