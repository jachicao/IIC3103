class CheckPurchaseOrdersWorker
  include Sidekiq::Worker

  def perform(*args)
    if ENV['DOCKER_RUNNING'].nil?
      return
    end
    # Do something
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
          when 'rechazada'
            purchase_order.destroy_purchase_order('Rejected by group')
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
        end
      else
        if purchase_order.dispatched
        else
          if purchase_order.sending
          else
            case purchase_order.status
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
