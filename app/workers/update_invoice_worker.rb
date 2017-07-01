class UpdateInvoiceWorker < ApplicationWorker
  sidekiq_options queue: 'critical'

  def perform(_id)
    invoice = Invoice.find_by(_id: _id)
    if invoice != nil
      if invoice.is_bill
      else
        purchase_order = invoice.get_purchase_order
        if purchase_order.nil?
          #invoice.destroy
          return nil
        end
      end
      server = self.get_invoice(invoice._id)
      if server[:code] == 200
        body = server[:body]
        if body != nil
          invoice.update(
              status: body[:estado],
              rejected_reason: body[:rechazo],
              cancelled_reason: body[:anulacion],
              created_at: DateTime.parse(body[:created_at]),
              updated_at: DateTime.parse(body[:updated_at]),
          )
        else
          #invoice.destroy
        end
      end
    end
  end
end
