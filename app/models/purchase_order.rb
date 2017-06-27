class PurchaseOrder < ApplicationRecord
  belongs_to :product

  def self.create_new(_id)
    purchase_order = PurchaseOrder.find_by(po_id: _id)
    if purchase_order != nil
      return purchase_order
    else
      server = self.get_server_details(_id)
      if server[:code] == 200
        body = server[:body]
        puts body
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
      DispatchProductsToAddressWorker.perform_async(self.po_id)
    elsif self.is_b2c
      DispatchProductsToAddressWorker.perform_async(self.po_id)
    elsif self.is_b2b
      DispatchProductsToStoreHouseWorker.perform_async(self.po_id)
    end
  end

  def confirm_dispatched
    if self.dispatched
    else
      if self.is_ftp
        self.update(dispatched: true)
      elsif self.is_b2c
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

  def cancel(causa)
    return CancelServerPurchaseOrderJob.perform_now(self.po_id, causa)
  end

  def get_invoices
    return Invoice.where(po_id: self.po_id)
  end

  def create_invoice
    if self.is_b2c
      return nil
    end
    self.get_invoices.each do |invoice|
      if invoice.is_paid
        return nil
      elsif invoice.is_pending
        return nil
      end
    end
    puts self.get_invoices.size
    puts 'Creating invoice'
    CreateInvoiceWorker.perform_async(self.po_id)
  end

  def is_paid
    self.get_invoices.each do |invoice|
      if invoice.is_paid
        return true
      end
    end
    return false
  end


  def pay_invoice
    if self.is_paid
      return nil
    end
    self.get_invoices.each do |invoice|
      if invoice.is_pending
        invoice.pay
      end
    end
  end

  def notify_invoice
    self.get_invoices.each do |invoice|
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

  def is_b2c
    return self.channel == 'b2c'
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
    return UpdatePurchaseOrderWorker.new.perform(self.po_id)
  end


  def update_properties_async
    return UpdatePurchaseOrderWorker.perform_async(self.po_id)
  end

  def update_quantity_dispatched
    #self.update(quantity_dispatched: self.quantity_dispatched + 1)
    PurchaseOrder.increment_counter(:quantity_dispatched, self.id)
  end

  def is_dispatching
    if self.is_made_by_me

    else
      if self.is_accepted
        quantity_left = self.quantity - self.quantity_dispatched
        if quantity_left > 0
          if self.product.stock - self.product.stock_in_despacho >= quantity_left
            return true
          end
        end
      end
    end
    return false
  end
end
