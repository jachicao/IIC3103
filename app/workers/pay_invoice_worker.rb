class PayInvoiceWorker < ApplicationWorker
  def perform(_id)
    invoice = Invoice.find_by(_id: _id)
    if invoice != nil
      purchase_order = invoice.get_purchase_order
      if purchase_order != nil
        transaction_response = self.transfer_money(invoice.bank_id, purchase_order.quantity * purchase_order.unit_price)
        transaction_id = transaction_response[:body][:_id]
        server = NotifyPaymentServerInvoiceJob.perform_now(invoice._id)
        group = nil
        if purchase_order.is_b2b
          group = NotifyPaymentGroupInvoiceJob.perform_now(invoice._id, invoice.get_supplier_group_number, transaction_id)
        end
        return {
            :server => server,
            :group => group,
        }
      end
    end
  end
end