class UpdateInvoicesStatusWorker
  include Sidekiq::Worker

  def perform(*args)
    Invoice.all.each do |invoice|
      server = GetInvoiceJob.perform_now(invoice._id)
      if server[:code] == 200
        body = server[:body]
        if body != nil
          invoice.update(
              status: body[:estado]
          )
        else
          invoice.destroy
        end
      end
    end
  end
end
