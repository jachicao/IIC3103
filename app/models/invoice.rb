class Invoice < ApplicationRecord
  belongs_to :purchase_order
  belongs_to :spree_order, class_name: 'Spree::Order'

  def get_server_details
    return GetInvoiceJob.perform_now(self._id)[:body].first
  end

  def self.bill_create(client, total_amount)
    return CreateBillJob.perform_now(client, total_amount)[:body]
  end

  def invoice_create(po_id)
    return CreateInvoiceJob.perform_now(po_id)[:body]
  end

  def self.url_create(bill)
    url = ENV['CENTRAL_SERVER_URL'] + '/web/pagoenlinea'
    url += "?callbackUrl=#{URI.escape('http://www.google.com', Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"
    url += "&cancelUrl=#{URI.escape('http://www.apple.com', Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"
    url += "&boletaId=#{bill[:_id]}"
  end
end
