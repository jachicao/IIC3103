class CheckPurchaseOrdersWorker
  include Sidekiq::Worker

  def perform(*args)
    PurchaseOrder.all.each do |purchase_order|
      server = GetPurchaseOrderJob.perform_now(purchase_order.po_id)
      if server[:code] == 200
        body = server[:body]
        if body != nil
          purchase_order.update(client_id: body[:cliente],
                                supplier_id: body[:proveedor],
                                delivery_date: DateTime.parse(body[:fechaEntrega]),
                                unit_price: body[:precioUnitario],
                                sku: body[:sku],
                                quantity: body[:cantidad],
                                status: body[:estado],
                                rejected_reason: body[:rechazo],
                                cancelled_reason: body[:anulacion],
                                channel: body[:canal],
          )
        else
          purchase_order.destroy
        end
      else
        purchase_order.destroy
      end
    end
    PurchaseOrder.all.each do |purchase_order|
      if purchase_order.is_made_by_me
        case purchase_order.status
          when 'aceptada'
            case purchase_order.payment_method
              when 'contra_factura'
                invoice = purchase_order.get_not_rejected_invoice
                if invoice != nil
                  if invoice.paid
                  else
                    invoice.pay
                  end
                end
            end
          when 'finalizada'
            case purchase_order.payment_method
              when 'contra_despacho'
                invoice = purchase_order.get_not_rejected_invoice
                if invoice != nil
                  if invoice.paid
                  else
                    invoice.pay
                  end
                end
            end
          when 'rechazada'
            purchase_order.destroy_purchase_order('Rejected by group')
          when 'anulada'
            purchase_order.destroy
        end
      else
        case purchase_order.status
          when 'aceptada'
            if purchase_order.dispatched
            else
              if purchase_order.sending
              else
                analysis = purchase_order.analyze_stock_to_dispatch
                if analysis != nil
                  if analysis <= 0
                    purchase_order.dispatch_order
                  end
                end
              end
            end
          when 'rechazada'
            purchase_order.destroy
          when 'anulada'
            purchase_order.destroy
        end
      end
    end
  end
end
