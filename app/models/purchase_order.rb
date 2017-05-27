class PurchaseOrder < ApplicationRecord

  def self.dispatch_purchase_order(producto_id, direccion, cantidad, precio_unitario,oc)
    response_movement = store_house.move_to_despacho(producto_id,cantidad)
    if response_movement[:message] == 'Movido a despacho'
      response_server = DispatchProductJob.perform(
        producto_id,
        direccion,
        cantidad*precio_unitario,
        oc,
      )
      case response_server[:code]
        when 200
          return true

        else
          puts response_server[:code]
          return nil
      end
    else
      return response_movement
    end
  end

  def self.create_new_purchase_order(producer_id, sku, delivery_date, quantity, unit_price, payment_method)
    recepcion = StoreHouse.get_recepciones
    if recepcion == nil
      return false
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
        return false
    end

    group_number = Producer.where(producer_id: producer_id).first.group_number
    response_group = CreateGroupPurchaseOrderJob.perform_now(
        group_number,
        response_server[:body][:_id],
        payment_method,
        id_almacen_recepcion,
    )

    case response_group[:code]
      when 201

      else
        CancelServerPurchaseOrderJob.perform_now(
              response_server[:body][:_id],
              "Rejected by group",
          )
        return false
    end


    @purchase_order = PurchaseOrder.new(po_id: response_server[:body][:_id],
                                        payment_method: payment_method,
                                        store_reception_id: id_almacen_recepcion,
                                        status: response_server[:body][:estado],
                                        own: true,
                                        dispatched: false)
    if @purchase_order.save
      return true
    else
      return false
    end
  end
end
