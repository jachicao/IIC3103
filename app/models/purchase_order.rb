class PurchaseOrder < ApplicationRecord
  belongs_to :product

  def self.create_new(_id)
    server = self.get_server_details(_id)
    if server[:code] == 200
      body = server[:body]
      return PurchaseOrder.create(
          po_id: body[:_id],
          status: body[:estado],
          rejected_reason: body[:rechazo],
          cancelled_reason: body[:anulacion],
          quantity_dispatched: body[:cantidadDespachada],
          server_quantity_dispatched: body[:cantidadDespachada],
          client_id: body[:cliente],
          supplier_id: body[:proveedor],
          delivery_date: DateTime.parse(body[:fechaEntrega]),
          unit_price: body[:precioUnitario],
          product: Product.find_by(sku: body[:sku]),
          quantity: body[:cantidad],
          channel: body[:canal],
      )
    else
      return nil
    end
  end

  def self.get_my_orders
    return PurchaseOrder.all.select { |v| v.is_made_by_me }
  end

  def self.get_client_orders
    return PurchaseOrder.all.select { |v| !v.is_made_by_me }
  end

  def self.get_server_details(_id)
    return GetPurchaseOrderWorker.new.perform(_id)
  end

  def analyze
    if self.analyzing
    else
      self.update(analyzing: true)
      AnalyzePurchaseOrderWorker.perform_async(self.po_id)
    end
  end

  def dispatch_order
    if self.is_ftp
      DispatchProductsToDistributorWorker.perform_async(self.po_id)
    elsif self.is_b2b
      DispatchProductsToBusinessWorker.perform_async(self.po_id)
    end
  end

  def confirm_dispatched
    if self.dispatched
    else
      if self.is_ftp
        self.update(dispatched: true)
      elsif self.is_b2b
        self.notify_invoice
      end
    end
  end

  def get_client
    producer = Producer.find_by(producer_id: self.client_id)
    if producer != nil
      return producer.group_number
    end
    return self.client_id
  end

  def get_supplier
    producer = Producer.find_by(producer_id: self.supplier_id)
    if producer != nil
      return producer.group_number
    end
    return self.supplier_id
  end


  def get_client_group_number
    producer = Producer.find_by(producer_id: self.client_id)
    if producer != nil
      return producer.group_number
    end
    return -1
  end

  def accept
    server = AcceptServerPurchaseOrderJob.perform_now(self.po_id)
    group = nil
    if self.is_b2b
      group = AcceptGroupPurchaseOrderJob.perform_now(get_client_group_number, self.po_id)
    end
    return {
        :server => server,
        :group => group,
    }
  end

  def reject(causa)
    server = RejectServerPurchaseOrderJob.perform_now(self.po_id, causa)
    group = nil
    if self.is_b2b
      group = RejectGroupPurchaseOrderJob.perform_now(get_client_group_number, self.po_id, causa)
    end
    return {
        :server => server,
        :group => group,
    }
  end

  def destroy_purchase_order(causa)
    self.cancel(causa)
    self.destroy
  end

  def cancel(causa)
    return CancelServerPurchaseOrderJob.perform_now(self.po_id, causa)
  end

  def get_invoices
    return Invoice.where(po_id: self.po_id)
  end

  def get_pending_invoice
    invoices = self.get_invoices
    invoices.each do |invoice|
      if invoice.is_pending
        return invoice
      end
    end
    return nil
  end

  def create_invoice
    invoice = self.get_pending_invoice
    if invoice.nil?
      Invoice.create_invoice(self.po_id)
    end
  end

  def pay_invoice
    invoice = self.get_pending_invoice
    if invoice != nil
      invoice.pay
    end
  end

  def notify_invoice
    invoice = self.get_pending_invoice
    if invoice != nil
      invoice.notify_dispatch
    end
  end

  def confirm_invoice_notified
    self.update(dispatched: true)
  end

  def is_made_by_me
    return self.client_id == ENV['GROUP_ID']
  end

  def is_b2b
    return self.channel == 'b2b'
  end

  def is_ftp
    return self.channel == 'ftp'
  end

  def is_created
    return self.status == 'creada'
  end

  def is_accepted
    return self.status == 'aceptada'
  end

  def is_completed
    return self.status == 'finalizada'
  end

  def is_rejected
    return self.status == 'rechazada'
  end

  def is_cancelled
    return self.status == 'anulada'
  end

  def is_dispatched
    return self.quantity <= self.quantity_dispatched
  end

  def update_properties_sync
    return UpdatePurchaseOrderWorker.new.perform(self.po_id, false)
  end


  def update_properties_async
    return UpdatePurchaseOrderWorker.perform_async(self.po_id, false)
  end

  def update_quantity_dispatched
    #self.update(quantity_dispatched: self.quantity_dispatched + 1)
    PurchaseOrder.increment_counter(:quantity_dispatched, self.id)
  end
end
