class UpdateInvoicesWorker < ApplicationWorker
  sidekiq_options queue: 'default'

  def perform(*args)
    Invoice.all.each do |invoice|
      if invoice.is_cancelled or invoice.is_rejected or invoice.is_paid
      else
        UpdateInvoiceWorker.perform_async(invoice._id)
      end
    end
  end
end
