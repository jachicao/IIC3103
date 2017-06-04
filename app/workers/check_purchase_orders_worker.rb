class CheckPurchaseOrdersWorker
  include Sidekiq::Worker

  def perform(*args)
    # Do something
    PurchaseOrder.all.each do |purchase_order|
      if purchase_order.is_made_by_me
        invoice = purchase_order.get_not_rejected_invoice
        if invoice != nil
          if invoice.paid
          else
            case purchase_order.payment_method
              when 'contra_despacho'
                server = PurchaseOrder.get_server_details(purchase_order.po_id)
                body = server[:body].first
                case body[:estado]
                  when 'finalizada'
                    invoice.pay
                end
              when 'contra_factura'
                invoice.pay
            end
          end
        end
      else
        if purchase_order.dispatched
        else
          if purchase_order.sending
          else
            server = PurchaseOrder.get_server_details(purchase_order.po_id)
            body = server[:body].first
            case body[:estado]
              when 'aceptada'
                analysis = purchase_order.analyze_stock_to_dispatch
                if analysis != nil
                  if analysis <= 0
                    purchase_order.dispatch_order
                  end
                end
            end
          end
        end
      end
    end
  end
end
