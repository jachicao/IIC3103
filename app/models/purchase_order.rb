class PurchaseOrder < ApplicationRecord
  belongs_to :product

  def self.get_my_orders
    return PurchaseOrder.all.select { |v| v.is_made_by_me }
  end

  def self.get_client_orders
    return PurchaseOrder.all.select { |v| !v.is_made_by_me }
  end

  def self.create_new_purchase_order(producer_id, sku, delivery_date, quantity, unit_price, payment_method)
    if quantity > 5000
      return {
          :success => false,
          :server => {},
          :group => {},
      }
    end

    id_almacen_recepcion = nil
    StoreHouse.all.each do |store_house|
      if store_house.recepcion
        id_almacen_recepcion = store_house._id
      end
    end

    response_server = CreateServerPurchaseOrderJob.perform_now(
        producer_id,
        sku,
        delivery_date,
        quantity,
        unit_price,
        'b2b',
        'sin notas',
    )
    case response_server[:code]
      when 200
      else
        return {
            :success => false,
            :server => response_server,
            :group => {},
        }
    end

    group_number = Producer.find_by(producer_id: producer_id).group_number
    response_group = CreateGroupPurchaseOrderJob.perform_now(
        group_number,
        response_server[:body][:_id],
        payment_method,
        id_almacen_recepcion,
    )
    case response_group[:code]
      when 200..226

      else
        CancelServerPurchaseOrderJob.perform_later(response_server[:body][:_id], 'Rejected by group')
        return {
            :success => false,
            :server => response_server,
            :group => response_group,
        }
    end


    body = response_server[:body]
    purchase_order = PurchaseOrder.new(po_id: body[:_id],
                                        payment_method: payment_method,
                                        store_reception_id: id_almacen_recepcion,
                                        client_id: body[:cliente],
                                        supplier_id: body[:proveedor],
                                        delivery_date: DateTime.parse(body[:fechaEntrega]),
                                        unit_price: body[:precioUnitario],
                                        product: Product.find_by(sku: body[:sku]),
                                        quantity: body[:cantidad],
                                        status: body[:estado],
                                        channel: body[:canal]
    )
    if purchase_order.save
      return {
          :success => true,
          :server => response_server,
          :group => response_group,
      }
    else
      return {
          :success => false,
          :server => response_server,
          :group => response_group,
      }
    end
  end


  def self.get_server_details(po_id)
    return GetPurchaseOrderJob.perform_now(po_id)
  end

  def analyze
    if self.analyzing
    else
      self.update(analyzing: true)
      AnalyzePurchaseOrderWorker.perform_async(self.po_id)
    end
  end

  def dispatch_order
    if self.sending
    else
      self.update(sending: true)
      if self.is_ftp
        self.create_invoice
        DispatchProductsToDistributorWorker.perform_async(self.po_id)
      elsif self.is_b2b
        if self.payment_method == 'contra_factura'
          self.create_invoice
        end
        DispatchProductsToBusinessWorker.perform_async(self.store_reception_id, self.po_id)
      end
    end
  end

  def confirm_dispatched
    if self.dispatched
    else
      self.update(dispatched: true)
      if self.is_b2b
        if self.payment_method == 'contra_despacho'
          self.create_invoice
        end
        invoice = self.get_invoice
        if invoice != nil
          invoice.notify_dispatch
        end
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

  def create_invoice
    return Invoice.create_invoice(self.po_id)
  end

  def get_invoices
    return Invoice.where(po_id: self.po_id)
  end

  def get_invoice
    return Invoice.find_by(po_id: self.po_id)
  end

  def pay_invoice
    invoice = self.get_invoice
    if invoice != nil
      invoice.pay
    end
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
    return self.status == 'aceptada'
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
end
