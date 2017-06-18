class CheckPurchaseOrdersWorker < ApplicationWorker
  sidekiq_options queue: 'default'

  def perform(*args)
    if true
      if $sending_purchase_order != nil
        purchase_order = PurchaseOrder.find_by(po_id: $sending_purchase_order)
        if purchase_order != nil
          if purchase_order.quantity_dispatched >= purchase_order.quantity
            $sending_purchase_order = nil
          end
        else
          $sending_purchase_order = nil
        end
      end
      ordered = PurchaseOrder.all.order(delivery_date: :asc)
      ordered.each do |purchase_order|
        if purchase_order.is_made_by_me
          if purchase_order.is_created
          elsif purchase_order.is_accepted
            case purchase_order.payment_method
              when 'contra_factura'
                purchase_order.pay_invoice
              when 'contra_despacho'
                if purchase_order.quantity_dispatched >= purchase_order.quantity
                  purchase_order.pay_invoice
                end
            end
          elsif purchase_order.is_rejected
            #purchase_order.destroy_purchase_order('Rejected by group')
          elsif purchase_order.is_cancelled
            purchase_order.destroy
          elsif purchase_order.is_completed
            purchase_order.pay_invoice
          end
        else
          if purchase_order.is_created
            purchase_order.analyze
          elsif purchase_order.is_accepted
            purchase_order.create_invoice
            if $sending_purchase_order == nil
              if purchase_order.quantity_dispatched < purchase_order.quantity
                if purchase_order.sending
                else
                  if purchase_order.product.stock - purchase_order.product.stock_in_despacho >= purchase_order.quantity
                    $sending_purchase_order = purchase_order.po_id
                    purchase_order.dispatch_order
                  end
                end
              end
            end
          elsif purchase_order.is_rejected
            #purchase_order.destroy
          elsif purchase_order.is_cancelled
            purchase_order.destroy
          elsif purchase_order.is_completed
            purchase_order.create_invoice
            purchase_order.confirm_dispatched
          end
        end
      end
    end
  end
end
