class GetInvoiceWorker < ApplicationWorker

  def perform(_id)
    return self.get_invoice(_id)
  end
end
