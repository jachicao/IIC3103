class AnalyzeInvoiceWorker < ApplicationWorker

  def perform(_id)
    invoice = Invoice.find_by(_id: _id)
    if invoice != nil and not invoice.is_bill
      if invoice.client_id == ENV['GROUP_ID']
        purchase_order = invoice.get_purchase_order
        if purchase_order != nil
          found = false
          purchase_order.get_invoices.each do |i|
            if i.accepted
              found = true
            end
          end
          if found
            invoice.reject('Invoice duplicated')
          else
            if invoice.amount >= purchase_order.unit_price * purchase_order.quantity
              invoice.accept
            else
              invoice.reject('Total de factura no equivale a precioUnitario * cantidad')
            end
          end
        else
          invoice.reject('Orden de Compra no encontrada')
        end
      else
        invoice.reject('cliente incorrecto')
      end
    end
  end
end
