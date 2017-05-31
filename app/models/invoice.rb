class Invoice < ApplicationRecord
  belongs_to :purchase_order

  def get_server_details
    return GetInvoiceJob.perform_now(self._id)[:body].first
  end

  def create_bill(client, total_amount)
    return CreateBillJob.perform_now(client, total_amount)[:body]
  end

  def create_invoice(po_id)
    return CreateInvoiceJob.perform_now(po_id)[:body]
  end

  def create_url(bill)
    url = ENV['CENTRAL_SERVER_URL']
  end
end
