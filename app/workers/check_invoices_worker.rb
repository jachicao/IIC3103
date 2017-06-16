class CheckInvoicesWorker < ApplicationWorker
  sidekiq_options queue: 'default'

  def perform(*args)
    Invoice.all.each do |invoice|
      if invoice.is_bill
      else
        if invoice.is_made_by_me
          if invoice.is_pending
          elsif invoice.is_rejected
            #invoice.destroy
          elsif invoice.is_cancelled
            #invoice.destroy
          elsif invoice.is_paid
          end
        else
          if invoice.is_pending
            invoice.analyze
          elsif invoice.is_rejected
            #invoice.destroy
          elsif invoice.is_cancelled
            #invoice.destroy
          elsif invoice.is_paid
          end
        end
      end
    end
  end
end
