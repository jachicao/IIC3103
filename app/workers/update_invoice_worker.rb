class UpdateInvoiceWorker < ApplicationWorker
  sidekiq_options queue: 'critical'

  def perform(_id)
    invoice = Invoice.find_by(_id: _id)
    if invoice != nil
      if invoice.is_bill
      else
        purchase_order = invoice.get_purchase_order
        if purchase_order.nil?
          invoice.destroy
          return nil
        end
      end
      server = self.get_invoice(invoice._id)
      if server[:code] == 200
        body = server[:body]
        if body != nil
          if body[:_id] != nil
            invoice.update(
                status: body[:estado],
                rejected_reason: body[:rechazo],
                cancelled_reason: body[:anulacion],
                supplier_id: body[:proveedor],
                client_id: body[:cliente],
                po_id: body[:oc],
                amount: body[:total],
            )
          else
            invoice.destroy
          end
        else
          invoice.destroy
        end
      else
        invoice.destroy
      end
    end
  end
end
