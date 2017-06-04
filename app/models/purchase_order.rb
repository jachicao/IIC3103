class PurchaseOrder < ApplicationRecord

  def self.get_my_orders
    return PurchaseOrder.all.select { |v| v.is_made_by_me }
  end

  def self.get_client_orders
    return PurchaseOrder.all.select { |v| !v.is_made_by_me }
  end

  def self.create_new_purchase_order(producer_id, sku, delivery_date, quantity, unit_price, payment_method)
    recepcion = StoreHouse.get_recepciones
    if recepcion == nil
      return nil
    end
    id_almacen_recepcion = recepcion.first[:_id]

    response_server = CreateServerPurchaseOrderJob.perform_now(
        ENV['GROUP_ID'],
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
                                        sku: body[:sku],
                                        quantity: body[:cantidad],
                                        status: body[:estado],
                                        own: true,
                                        dispatched: false)
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

  def analyze_stock_to_dispatch
    total = StoreHouse.get_stock_total_not_despacho(self.sku)
    if total.nil?
      return nil
    end
    if total >= self.quantity
      return 0
    else
      return self.quantity - total
    end
  end

  def dispatch_order
    if self.sending
    else
      if self.payment_method == 'contra_factura'
        self.create_invoice
      end
      DispatchProductsToGroupWorker.perform_async(self.store_reception_id, self.sku, self.quantity, self.po_id, self.unit_price)
      self.update(sending: true)
    end
  end

  def confirm_dispatched
    if self.dispatched
    else
      self.update(dispatched: true)
      if self.payment_method == 'contra_despacho'
        self.create_invoice
      end
      invoice = self.get_not_rejected_invoice
      if invoice != nil
        self.get_not_rejected_invoice.notify_dispatch
      end
    end
  end

  def get_client
    return Producer.find_by(producer_id: self.client_id)
  end

  def get_supplier
    return Producer.find_by(producer_id: self.supplier_id)
  end

  def get_product
    return Product.find_by(sku: self.sku)
  end

  def accept_purchase_order
    server = AcceptServerPurchaseOrderJob.perform_now(self.po_id)
    group = AcceptGroupPurchaseOrderJob.perform_now(get_client.group_number, self.po_id)
    return {
        :server => server,
        :group => group,
    }
  end

  def reject_purchase_order(causa)
    server = RejectServerPurchaseOrderJob.perform_now(self.po_id, causa)
    group = RejectGroupPurchaseOrderJob.perform_now(get_client.group_number, self.po_id, causa)
    return {
        :server => server,
        :group => group,
    }
  end

  def cancel_purchase_order(causa)
    return CancelServerPurchaseOrderJob.perform_now(self.po_id, causa)
  end

  def create_invoice
    return Invoice.create_invoice(self.po_id)
  end

  def get_invoices
    return Invoice.where(po_id: self.po_id)
  end

  def get_not_rejected_invoice
    self.get_invoices.each do |invoice|
      if invoice.rejected
      else
        return invoice
      end
    end
    return nil
  end

  def is_made_by_me
    return self.client_id == ENV['GROUP_ID']
  end
end
