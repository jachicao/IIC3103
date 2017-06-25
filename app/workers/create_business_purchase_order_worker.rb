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

    server = CreateServerPurchaseOrderJob.perform_now(
        ENV['GROUP_ID'],
        producer_id,
        sku,
        delivery_date,
        quantity,
        unit_price,
        'b2b',
    )
    case server[:code]
      when 200
      else
        return {
            :success => false,
            :server => server,
            :group => {},
        }
    end

    group_number = Producer.find_by(producer_id: producer_id).group_number
    group = CreateGroupPurchaseOrderJob.perform_now(
        group_number,
        server[:body][:_id],
        payment_method,
        id_almacen_recepcion,
    )
    case group[:code]
      when 200..226

      else
        CancelServerPurchaseOrderJob.perform_later(server[:body][:_id], 'Rejected by group')
        return {
            :success => false,
            :server => server,
            :group => group,
        }
    end
    body = server[:body]
    purchase_order = PurchaseOrder.create_new(body[:_id])
    if purchase_order != nil
      purchase_order.update(
          payment_method: payment_method,
          store_reception_id: id_almacen_recepcion)
      return {
          :success => true,
          :server => server,
          :group => group,
      }
    else
      return {
          :success => false,
          :server => server,
          :group => group,
      }
    end
  end
end
