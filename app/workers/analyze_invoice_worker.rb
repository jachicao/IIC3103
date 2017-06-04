class AnalyzeInvoiceWorker
  include Sidekiq::Worker

  def perform(_id)
    invoice = Invoice.find_by(_id: _id)
    if invoice.client_id == ENV['GROUP_ID']
      purchase_order = invoice.get_purchase_order
      if purchase_order != nil
        invoice.accept
      else
        invoice.reject('Orden de Compra no encontrada')
      end
    else
      invoice.reject('cliente incorrecto')
    end
  end
end
