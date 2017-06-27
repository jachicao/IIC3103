class CheckPurchaseOrdersWorker < ApplicationWorker
  sidekiq_options queue: 'default'

  def perform(*args)
    if true#ENV['DOCKER_RUNNING'] != nil
      sending = false
      ordered = PurchaseOrder.all.order(delivery_date: :asc)
      ordered.each do |purchase_order|
        if purchase_order.is_made_by_me
          if purchase_order.is_created
          elsif purchase_order.is_accepted
            case purchase_order.payment_method
              when 'contra_factura'
                if true

                end
              when 'contra_despacho'
                if purchase_order.is_dispatched
                end
            end
            purchase_order.pay_invoice
          elsif purchase_order.is_rejected
          elsif purchase_order.is_cancelled
          elsif purchase_order.is_completed
            purchase_order.pay_invoice
          end
        else
          if purchase_order.is_created
            purchase_order.analyze
          elsif purchase_order.is_accepted
            purchase_order.create_invoice
            if sending == false
              quantity_left = purchase_order.quantity - purchase_order.quantity_dispatched
              if quantity_left > 0
                if purchase_order.product.stock - purchase_order.product.stock_in_despacho >= quantity_left
                  sending = true
                  purchase_order.dispatch_order
                end
              end
            end
          elsif purchase_order.is_rejected
          elsif purchase_order.is_cancelled
          elsif purchase_order.is_completed
            purchase_order.create_invoice
            purchase_order.confirm_dispatched
          end
        end
      end
    end
  end
end
