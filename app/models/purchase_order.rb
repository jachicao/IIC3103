class PurchaseOrder < ApplicationRecord
  has_one :invoice

  def self.create_new_purchase_order(producer_id, sku, delivery_date, quantity, unit_price, payment_type)
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

    group_number = Producer.where(producer_id: producer_id).first.group_number
    response_group = CreateGroupPurchaseOrderJob.perform_now(
        group_number,
        response_server[:body][:_id],
        payment_type,
        id_almacen_recepcion,
    )
    case response_group[:code]
      when 200..226

      else
        CancelServerPurchaseOrderJob.perform_now(
              response_server[:body][:_id],
              'Rejected by group',
          )
        return {
            :success => false,
            :server => response_server,
            :group => response_group,
        }
    end



    @purchase_order = PurchaseOrder.new(po_id: response_server[:body][:_id],
                                        payment_method: payment_type,
                                        store_reception_id: id_almacen_recepcion,
                                        own: true,
                                        dispatched: false)
    if @purchase_order.save
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

  def get_server_details
    return GetPurchaseOrderJob.perform_now(self.po_id)
  end


  def analyze_stock_to_dispatch(sku, quantity)
    total = StoreHouse.get_stock_total_not_despacho(sku)
    if total.nil?
      return nil
    end
    if total >= quantity
      return 0
    else
      return quantity - total
    end
  end

  def dispatch_order(sku, quantity, price)
    DispatchProductsToGroupWorker.perform_async(store_reception_id, sku, quantity, po_id, price)
  end

  def confirm_dispatched
    self.dispatched = true
    self.save
  end
end
