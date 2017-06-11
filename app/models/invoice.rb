class Invoice < ApplicationRecord
  belongs_to :spree_order, class_name: 'Spree::Order'

  def self.bill_create(client, amount)
    return CreateBillJob.perform_now(client, amount)[:body]
  end

  def self.url_create(bill)
    urlok = (ENV['GROUPS_SERVER_URL'] % [ENV['GROUP_NUMBER'].to_i]) + '/spree'
    urlfail = (ENV['GROUPS_SERVER_URL'] % [ENV['GROUP_NUMBER'].to_i]) + '/spree/cart'
    url = ENV['CENTRAL_SERVER_URL'] + '/web/pagoenlinea'
    url += "?callbackUrl=#{URI.escape(urlok, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"
    url += "&cancelUrl=#{URI.escape(urlfail, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"
    url += "&boletaId=#{bill[:_id]}"
    return url
  end

  def self.create_invoice(po_id)
    purchase_order = PurchaseOrder.find_by(po_id: po_id)
    server = CreateServerInvoiceJob.perform_now(po_id)
    case server[:code]
      when 200..226

      else
        return {
            :success => false,
            :server => server,
            :group => {},
        }
    end
    body = server[:body]
    group = nil
    if purchase_order.is_b2b
      group = CreateGroupInvoiceJob.perform_now(po_id, purchase_order.get_client_group_number, Bank.get_bank_id)
      case group[:code]
        when 200..226
        else
          #self.cancel_invoice(body[:_id], 'Rejected by group')
          #return {
          #    :success => false,
          #    :server => server,
          #    :group => group,
          #}
      end
    end

    Invoice.create( #TODO
        _id: body[:_id],
        supplier_id: body[:proveedor],
        client_id: body[:cliente],
        po_id: body[:oc][:_id],
        status: body[:estado],
        amount: body[:total],
    )
    return {
        :success => true,
        :server => server,
        :group => group,
    }
  end


  def self.get_server_details(id)
    return GetInvoiceJob.perform_now(id)
  end

  def self.cancel_invoice(id, reason)
    return CancelServerInvoiceJob.perform_now(id, reason)
  end

  def get_supplier
    return Producer.find_by(producer_id: self.supplier_id)
  end

  def get_client
    return Producer.find_by(producer_id: self.client_id)
  end

  def accept
    group = AcceptGroupInvoiceJob.perform_now(self._id, get_supplier.group_number)
    return {
        :group => group
    }
  end

  def reject(reason)
    server = RejectServerInvoiceJob.perform_now(self._id, reason)
    group = RejectGroupInvoiceJob.perform_now(self._id, get_supplier.group_number, reason)
    self.update(rejected: true)
    return {
        :server => server,
        :group => group,
    }
  end

  def pay
    if self.paid
    else
      self.update(paid: true)
      transaction = nil
      purchase_order = get_purchase_order
      amount = purchase_order.quantity * purchase_order.unit_price
      while transaction.nil?
        transaction = Bank.transfer_money(self.bank_id, amount)
      end
      server = NotifyPaymentServerInvoiceJob.perform_now(self._id)
      group = NotifyPaymentGroupInvoiceJob.perform_now(self._id, get_supplier.group_number, transaction[:body][:_id])
      return {
          :server => server,
          :group => group,
      }
    end
  end

  def notify_dispatch
    group = NotifyDispatchGroupInvoiceJob.perform_now(self._id, get_client.group_number)
    return {
        :group => group
    }
  end

  def get_purchase_order
    return PurchaseOrder.find_by(po_id: self.po_id)
  end

  def is_made_by_me
    return !self.get_purchase_order.is_made_by_me
  end

  def is_pending
    return self.status == 'pendiente'
  end

  def is_paid
    return self.status == 'pagado'
  end

  def is_cancelled
    return self.status == 'anulada'
  end

  def is_rejected
    return self.status == 'rechazada'
  end
end
