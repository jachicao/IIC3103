class UpdateInvoicesStatusWorker
  include Sidekiq::Worker

  def perform(*args)
    Invoice.all.each do |invoice|
      server = GetInvoiceJob.perform_now(invoice._id)
      if server[:code] == 200
        body = server[:body]
        invoice.update(
            status: body[:estado]
        )
      end
    end
  end
end
