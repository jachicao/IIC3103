class CreateBusinessPurchaseOrderWorker < ApplicationWorker

  def perform(producer_id, sku, delivery_date, quantity, unit_price, payment_method)
    if quantity > 5000
      return {
          :success => false,
          :server => {},
          :group => {},
      }
    end

    id_almacen_recepcion = StoreHouse.get_recepcion._id

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
    purchase_order = PurchaseOrder.create_new(body[:_id])
    if purchase_order != nil
      purchase_order.update(
          payment_method: payment_method,
          store_reception_id: id_almacen_recepcion)
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
end
