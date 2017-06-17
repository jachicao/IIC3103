class UpdateAllInvoicesWorker < ApplicationWorker

  def perform(*args)
    Invoice.all.each do |invoice|
      UpdateInvoiceWorker.perform_async(invoice._id)
    end
  end
end
