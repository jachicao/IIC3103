class UpdateInvoiceWorker < ApplicationWorker
  sidekiq_options queue: 'default'

  def perform(_id)
    invoice = Invoice.find_by(_id: _id)
    if invoice != nil
      server = self.get_invoice(invoice._id)
      if server[:code] == 200
        body = server[:body]
        if body != nil
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
    end
  end
end
