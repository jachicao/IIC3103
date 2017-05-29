class Invoice < ApplicationRecord
  belongs_to :purchase_order

  def get_server_details
    return GetInvoiceJob.perform_now(self._id)[:body].first
  end
end
