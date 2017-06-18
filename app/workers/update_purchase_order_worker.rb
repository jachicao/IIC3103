class UpdatePurchaseOrderWorker < ApplicationWorker
  sidekiq_options queue: 'critical'

  def perform(po_id)
    purchase_order = PurchaseOrder.find_by(po_id: po_id)
    if purchase_order != nil
      server = self.get_purchase_order(purchase_order.po_id)
      if server[:code] == 200
        body = server[:body]
        purchase_order.update(status: body[:estado],
                              rejected_reason: body[:rechazo],
                              cancelled_reason: body[:anulacion],
                              server_quantity_dispatched: body[:cantidadDespachada],
                              client_id: body[:cliente],
                              supplier_id: body[:proveedor],
                              delivery_date: DateTime.parse(body[:fechaEntrega]),
                              unit_price: body[:precioUnitario],
                              product: Product.find_by(sku: body[:sku]),
                              quantity: body[:cantidad],
                              channel: body[:canal],
        )
      else
        purchase_order.destroy
      end
    end
  end
end