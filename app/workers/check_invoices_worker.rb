class CheckInvoicesWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'

  def perform(*args)
    if true
      return nil
    end
    Invoice.all.each do |invoice|
      server = GetInvoiceJob.perform_now(invoice._id)
      if server[:code] == 200
        body = server[:body]
        if body != nil
          invoice.update(
              status: body[:estado],
              rejected_reason: body[:rechazo],
              cancelled_reason: body[:anulacion],
          )
        else
          invoice.destroy
        end
      else
        invoice.destroy
      end
    end
    Invoice.all.each do |invoice|
      if invoice.is_bill
      else
        if invoice.is_made_by_me
          case invoice.status
            when 'pendiente'

            when 'pagado'

            when 'anulada'

            when 'rechazada'
          end
        else
          case invoice.status
            when 'pendiente'

            when 'pagado'

            when 'anulada'

            when 'rechazada'
          end
        end
      end
    end
  end
end
