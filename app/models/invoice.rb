class Invoice < ApplicationRecord
  belongs_to :spree_order, class_name: 'Spree::Order'
  has_many :bill_items, dependent: :destroy

  def get_bill_url
    if ENV['DOCKER_RUNNING'] != nil
      base_url = Producer.get_me.get_base_url
    else
      base_url = 'http://localhost:3000'
    end
    url = ENV['CENTRAL_SERVER_URL'] + '/web/pagoenlinea'
    url += "?callbackUrl=#{URI.escape(base_url + '/bills/' + self.id.to_s + '/paid', Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"
    url += "&cancelUrl=#{URI.escape(base_url + '/bills/' + self.id.to_s + '/failed', Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"
    url += "&boletaId=#{self._id}"
    return url
  end

  def self.create_new(_id)
    server = self.get_server_details(_id)
    if server[:code] == 200
      body = server[:body]
      return Invoice.create(
          _id: body[:_id],
          status: body[:estado],
          rejected_reason: body[:rechazo],
          cancelled_reason: body[:anulacion],
          supplier_id: body[:proveedor],
          client_id: body[:cliente],
          po_id: body[:oc],
          amount: body[:total],
      )
    else
      return nil
    end
  end

  def self.create_bill(client, amount)
    return CreateBillWorker.new.perform(client, amount)
  end

  def self.create_invoice(po_id)
    return CreateInvoiceWorker.perform_async(po_id)
  end

  def self.get_server_details(_id)
    return GetInvoiceWorker.new.perform(_id)
  end

  def self.cancel_invoice(id, reason)
    #return CancelServerInvoiceJob.perform_now(id, reason)
  end

  def bill_paid
    Spree::Order.delete_all
    self.bill_items.each do |bill_item|
      CreateConsumerPurchaseOrderWorker.perform_async(
          self._id,
          self.client_id,
          bill_item.product.sku,
          (Time.now + 1.to_f.hours).to_i * 1000,
          bill_item.quantity,
          bill_item.unit_price
      )
    end
  end

  def bill_failed
    #Spree::Order.delete_all
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
    self.update(accepted: true)
    group = nil
    if self.is_b2b
      group = AcceptGroupInvoiceJob.perform_now(self.get_supplier_group_number, self._id)
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

  def get_bank_account
    group_number = self.get_supplier_group_number
    producer = Producer.find_by(group_number: group_number)
    if producer != nil && producer.bank_account != nil && producer.bank_account != ''
      return producer.bank_account
    end
    return self.bank_id
  end

  def notify_dispatch
    group = nil
    if self.is_b2b
      group = NotifyDispatchGroupInvoiceJob.perform_now(self.get_client_group_number, self._id)
      purchase_order = self.get_purchase_order
      if purchase_order != nil
        purchase_order.confirm_invoice_notified
      end
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
    return self.status == 'pagada'
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

  def update_properties_async
    UpdateInvoiceWorker.perform_async(self._id)
  end

  def is_bill
    return self.po_id == '000000000000000000000000'
  end
end
