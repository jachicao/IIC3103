class Invoice < ApplicationRecord
  belongs_to :spree_order, class_name: 'Spree::Order'

  def self.bill_create(client, amount)
    return CreateBillJob.perform_now(client, amount)[:body]
  end

  def self.url_create(bill)
    me = Producer.get_me
    urlok = me.get_base_url + '/spree'
    urlfail = me.get_base_url + '/spree/cart'
    url = ENV['CENTRAL_SERVER_URL'] + '/web/pagoenlinea'
    url += "?callbackUrl=#{URI.escape(urlok, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"
    url += "&cancelUrl=#{URI.escape(urlfail, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"
    url += "&boletaId=#{bill[:_id]}"
    return url
  end

  def self.create_invoice(po_id)
    purchase_order = PurchaseOrder.find_by(po_id: po_id)
    if purchase_order != nil
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
        group = CreateGroupInvoiceJob.perform_now(purchase_order.get_client_group_number, body[:_id])
        puts 'GRUPO  ' + purchase_order.get_client_group_number.to_s
        puts group
        case group[:code]
          when 200..226
          else
            self.cancel_invoice(body[:_id], 'Rejected by group')
            return {
                :success => false,
                :server => server,
                :group => group,
            }
        end
      end

      invoice = Invoice.create(
          _id: body[:_id],
      )
      invoice.update_properties
      return {
          :success => true,
          :server => server,
          :group => group,
      }
    end
  end


  def self.get_server_details(id)
    return GetInvoiceWorker.new.perform(id)
  end

  def self.cancel_invoice(id, reason)
    return CancelServerInvoiceJob.perform_now(id, reason)
  end

  def get_supplier_group_number
    producer = Producer.find_by(producer_id: self.supplier_id)
    if producer != nil
      return producer.group_number
    end
    return -1
  end

  def get_client_group_number
    producer = Producer.find_by(producer_id: self.client_id)
    if producer != nil
      return producer.group_number
    end
    return -1
  end

  def get_supplier
    producer = Producer.find_by(producer_id: self.supplier_id)
    if producer != nil
      return producer.group_number
    end
    return self.supplier_id
  end

  def get_client
    producer = Producer.find_by(producer_id: self.client_id)
    if producer != nil
      return producer.group_number
    end
    return self.client_id
  end

  def analyze
    if self.analyzing
    else
      self.update(analyzing: true)
      AnalyzeInvoiceWorker.perform_async(self._id)
    end
  end

  def accept
    group = nil
    if self.is_b2b
      group = AcceptGroupInvoiceJob.perform_now(get_supplier_group_number, self._id)
    end
    return {
        :group => group
    }
  end

  def reject(reason)
    server = RejectServerInvoiceJob.perform_now(self._id, reason)
    group = nil
    if self.is_b2b
      group = RejectGroupInvoiceJob.perform_now(self.get_supplier_group_number, self._id, reason)
    end
    return {
        :server => server,
        :group => group,
    }
  end

  def pay
    if self.paid
    else
      self.update(paid: true)
      PayInvoiceWorker.perform_async(self._id)
    end
  end

  def notify_dispatch
    group = nil
    if self.is_b2b
      group = NotifyDispatchGroupInvoiceJob.perform_now(self.get_client_group_number, self._id)
      self.get_purchase_order.confirm_invoice_notified
    end
    return {
        :group => group
    }
  end

  def get_purchase_order
    return PurchaseOrder.find_by(po_id: self.po_id)
  end

  def is_made_by_me
    return self.supplier_id == ENV['GROUP_ID']
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

  def is_b2b
    purchase_order = self.get_purchase_order
    if purchase_order != nil
      return purchase_order.is_b2b
    end
    return false
  end

  def update_properties
    UpdateInvoiceWorker.perform_async(self._id)
  end
end
