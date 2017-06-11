class CheckPurchaseOrdersWorker
  include Sidekiq::Worker

  def perform(*args)
    if ENV['DOCKER_RUNNING'].nil?
      return
    end
    PurchaseOrder.all.each do |purchase_order|
      if purchase_order.is_made_by_me
        if purchase_order.is_created
        elsif purchase_order.is_accepted
          case purchase_order.payment_method
            when 'contra_factura'
              purchase_order.pay_invoice
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
          if purchase_order.dispatched
          else
            if purchase_order.sending
            else
              if purchase_order.product.stock - purchase_order.product.stock_in_despacho >= purchase_order.quantity
                purchase_order.dispatch_order
              end
            end
          end
        elsif purchase_order.is_rejected
          #purchase_order.destroy
        elsif purchase_order.is_cancelled
          purchase_order.destroy
        elsif purchase_order.is_completed
        end
      end
    end
  end
end
